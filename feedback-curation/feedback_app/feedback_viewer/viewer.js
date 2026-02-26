/* Feedback Item Viewer - standalone explorer for annotator JSON files */

const DATA_SOURCES = [
  { key: "im", label: "IM", path: "../data/csv_curator_labels_im.json" },
  { key: "nn", label: "NN", path: "../data/csv_curator_labels_nn.json" },
  { key: "jw", label: "JW", path: "../data/csv_curator_labels_jw.json" },
  { key: "hm", label: "HM", path: "../data/csv_curator_labels_hm.json" },
];

let data = { im: [], nn: [], jw: [], hm: [] };
let allItems = [];
let filteredItems = [];
let currentPage = 1;
let perPage = 50;

const AGENT_LABELS = {
  novelty: "Novelty",
  scope: "Scope",
  ethics: "Ethics",
  methodology_reporting: "Methodology Reporting",
  methodology_validation: "Methodology Validation",
  integrity: "Integrity",
};

/* ── Load data ─────────────────────────────────────────────── */
async function loadFromPaths() {
  const status = document.getElementById("load-status");
  status.textContent = "Loading…";
  try {
    for (const src of DATA_SOURCES) {
      const res = await fetch(src.path);
      if (!res.ok) throw new Error(`${src.label}: ${res.status}`);
      data[src.key] = await res.json();
    }
    status.textContent = "Loaded successfully.";
    buildItems();
    showMain();
  } catch (err) {
    status.textContent = `Failed: ${err.message}. Use "Load JSON files" to select files manually.`;
    status.style.color = "#e74c3c";
  }
}

function loadFromFiles(files) {
  const status = document.getElementById("load-status");
  status.textContent = "Loading files…";
  const keyByFilename = {
    "csv_curator_labels_im.json": "im",
    "csv_curator_labels_nn.json": "nn",
    "csv_curator_labels_jw.json": "jw",
    "csv_curator_labels_hm.json": "hm",
  };
  let loaded = 0;
  const promises = Array.from(files).map((file) => {
    const key = keyByFilename[file.name];
    if (!key) return Promise.resolve();
    return new Promise((resolve, reject) => {
      const r = new FileReader();
      r.onload = () => {
        try {
          data[key] = JSON.parse(r.result);
          loaded++;
          resolve();
        } catch (e) {
          reject(e);
        }
      };
      r.onerror = () => reject(new Error(`Failed to read ${file.name}`));
      r.readAsText(file);
    });
  });
  Promise.all(promises)
    .then(() => {
      status.textContent = `Loaded ${loaded} file(s).`;
      buildItems();
      showMain();
    })
    .catch((err) => {
      status.textContent = `Error: ${err.message}`;
      status.style.color = "#e74c3c";
    });
}

function buildItems() {
  allItems = [];
  for (const [key, items] of Object.entries(data)) {
    if (!Array.isArray(items)) continue;
    items.forEach((item, idx) => {
      allItems.push({
        ...item,
        _annotator: key,
        _index: idx,
      });
    });
  }
  applyFilters();
}

function showMain() {
  document.getElementById("main").style.display = "grid";
  renderStats();
  renderList();
  setupFilters();
  setupPagination();
}

/* ── Stats ────────────────────────────────────────────────── */
function computeStats(items) {
  const total = items.length;
  const bySentiment = { positive: 0, neutral: 0, negative: 0, bug: 0, unlabeled: 0 };
  items.forEach((i) => {
    const s = i.sentiment_label;
    if (s && bySentiment[s] !== undefined) bySentiment[s]++;
    else bySentiment.unlabeled++;
  });
  return { total, bySentiment };
}

function renderStats() {
  const container = document.getElementById("stats-container");
  const annotators = DATA_SOURCES.map(s => ({ key: s.key, label: s.label }));
  container.innerHTML = annotators
    .map(({ key, label }) => {
      const items = data[key] || [];
      const stats = computeStats(items);
      const sentStr = Object.entries(stats.bySentiment)
        .filter(([, v]) => v > 0)
        .map(([k, v]) => `${k}: ${v}`)
        .join(", ");
      return `
        <div class="stat-box ${key}">
          <div class="num">${stats.total}</div>
          <div class="label">${label}</div>
          <div class="sub">${sentStr}</div>
        </div>
      `;
    })
    .join("");

  const total = allItems.length;
  const totalStats = computeStats(allItems);
  container.innerHTML += `
    <div class="stat-box" style="grid-column:1/-1; border-left-color:var(--purple)">
      <div class="num">${total}</div>
      <div class="label">Total items (combined)</div>
      <div class="sub">${Object.entries(totalStats.bySentiment)
        .filter(([, v]) => v > 0)
        .map(([k, v]) => `${k}: ${v}`)
        .join(", ")}</div>
    </div>
  `;
}

/* ── Filters ──────────────────────────────────────────────── */
function applyFilters() {
  const annotator = document.getElementById("filter-annotator")?.value || "all";
  const sentiment = document.getElementById("filter-sentiment")?.value || "all";
  const search = (document.getElementById("filter-search")?.value || "").trim().toLowerCase();
  perPage = parseInt(document.getElementById("filter-per-page")?.value || "50", 10);

  filteredItems = allItems.filter((item) => {
    if (annotator !== "all" && item._annotator !== annotator) return false;
    if (sentiment !== "all") {
      const s = item.sentiment_label;
      if (sentiment === "unlabeled") {
        if (s) return false;
      } else if (s !== sentiment) return false;
    }
    if (search) {
      const text = [
        item.feedback_text || "",
        item.question || "",
        item.item_id || "",
        JSON.stringify(item.agent_ratings || {}),
      ].join(" ");
      if (!text.toLowerCase().includes(search)) return false;
    }
    return true;
  });

  currentPage = 1;
  document.getElementById("result-count").textContent =
    `${filteredItems.length} item(s)`;
  renderList();
}

function setupFilters() {
  ["filter-annotator", "filter-sentiment", "filter-search", "filter-per-page"].forEach(
    (id) => {
      const el = document.getElementById(id);
      if (el) el.addEventListener("change", applyFilters);
      if (el && el.type === "text")
        el.addEventListener("input", debounce(applyFilters, 300));
    }
  );
}

function debounce(fn, ms) {
  let t;
  return (...args) => {
    clearTimeout(t);
    t = setTimeout(() => fn(...args), ms);
  };
}

/* ── Pagination ───────────────────────────────────────────── */
function setupPagination() {
  document.getElementById("btn-prev").onclick = () => {
    currentPage--;
    renderList();
  };
  document.getElementById("btn-next").onclick = () => {
    currentPage++;
    renderList();
  };
}

/* ── List render ─────────────────────────────────────────── */
function renderList() {
  const total = filteredItems.length;
  const totalPages = Math.max(1, Math.ceil(total / perPage));
  currentPage = Math.min(Math.max(1, currentPage), totalPages);

  const start = (currentPage - 1) * perPage;
  const pageItems = filteredItems.slice(start, start + perPage);

  document.getElementById("btn-prev").disabled = currentPage <= 1;
  document.getElementById("btn-next").disabled = currentPage >= totalPages;
  document.getElementById("page-info").textContent =
    total === 0
      ? "No items"
      : `Page ${currentPage} of ${totalPages} (${start + 1}–${Math.min(start + perPage, total)} of ${total})`;

  const list = document.getElementById("item-list");
  list.innerHTML = pageItems
    .map((item) => {
      const text = (item.feedback_text || "").trim();
      const preview = text.length > 150 ? text.slice(0, 150) + "…" : text;
      const sent = item.sentiment_label;
      const tagClass = sent || "unlabeled";
      const tagLabel = sent ? sent : "unlabeled";
      return `
        <div class="item-card ${item._annotator}" data-index="${item._index}" data-annotator="${item._annotator}">
          <div class="meta">
            <span class="id">${escapeHtml(item.item_id)}</span>
            <span class="tag ${tagClass}">${tagLabel}</span>
            <span>${item._annotator.toUpperCase()}</span>
            ${item.board_id ? `<span>${escapeHtml(item.board_id)}</span>` : ""}
            ${item.question_type ? `<span>${escapeHtml(item.question_type)}</span>` : ""}
          </div>
          <div class="preview">${escapeHtml(preview || "(no text)")}</div>
        </div>
      `;
    })
    .join("");

  list.querySelectorAll(".item-card").forEach((card) => {
    card.addEventListener("click", () => {
      const annotator = card.dataset.annotator;
      const index = parseInt(card.dataset.index, 10);
      const item = data[annotator][index];
      showDetail(item, annotator);
    });
  });
}

function escapeHtml(s) {
  if (s == null) return "";
  const div = document.createElement("div");
  div.textContent = String(s);
  return div.innerHTML;
}

/* ── Detail modal ─────────────────────────────────────────── */
function showDetail(item, annotator) {
  const modal = document.getElementById("detail-modal");
  const body = document.getElementById("detail-body");

  const sections = [
    {
      title: "ID & Source",
      value: [
        `Item ID: ${item.item_id || "—"}`,
        `Annotator: ${annotator.toUpperCase()}`,
        item.board_id ? `Board: ${item.board_id}` : null,
        item.source_file ? `Source: ${item.source_file}` : null,
        item.source_csv ? `CSV: ${item.source_csv}` : null,
      ]
        .filter(Boolean)
        .join("\n"),
    },
    {
      title: "Question",
      value: item.question || "—",
    },
    {
      title: "Feedback Text",
      value: item.feedback_text || "—",
    },
    {
      title: "Sentiment",
      value: item.sentiment_label
        ? `<span class="tag ${item.sentiment_label}">${item.sentiment_label}</span>`
        : "unlabeled",
      html: true,
    },
  ];

  if (item.agent_ratings && Object.keys(item.agent_ratings).length) {
    sections.push({
      title: "Agent Ratings",
      value: Object.entries(item.agent_ratings)
        .map(
          ([a, r]) =>
            `${AGENT_LABELS[a] || a}: ${r}`
        )
        .join("\n"),
    });
  }

  if (item.related_agents_label && item.related_agents_label.length) {
    sections.push({
      title: "Related Agents",
      value: item.related_agents_label
        .map((a) => AGENT_LABELS[a] || a)
        .join(", "),
    });
  }

  sections.push({
    title: "Raw JSON",
    value: JSON.stringify(item, null, 2),
    json: true,
  });

  body.innerHTML = sections
    .map((s) => {
      const cls = s.json ? "value json" : "value";
      const content = s.html
        ? s.value
        : escapeHtml(s.value);
      return `
        <div class="detail-section">
          <h3>${escapeHtml(s.title)}</h3>
          <div class="${cls}">${content}</div>
        </div>
      `;
    })
    .join("");

  modal.classList.add("open");
  modal.setAttribute("aria-hidden", "false");
}

function closeModal() {
  const modal = document.getElementById("detail-modal");
  modal.classList.remove("open");
  modal.setAttribute("aria-hidden", "true");
}

document.querySelector(".modal-backdrop").addEventListener("click", closeModal);
document.querySelector(".modal-close").addEventListener("click", closeModal);
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closeModal();
});

/* ── Init ─────────────────────────────────────────────────── */
document.getElementById("btn-load-default").addEventListener("click", loadFromPaths);
document.getElementById("file-input").addEventListener("change", (e) => {
  const files = e.target.files;
  if (files && files.length) loadFromFiles(files);
});
