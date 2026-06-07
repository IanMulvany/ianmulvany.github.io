const state = {
  catalog: null,
  route: "papers",
  routeParam: "",
  query: "",
  selectedPaperId: "",
  selectedAuthorId: "",
  figureSource: "all",
  figureAuthor: "all",
  figurePaper: "all",
  modalFigureId: "",
};

const app = document.querySelector("#app");
const searchInput = document.querySelector("#global-search");
const sectionTitle = document.querySelector("#section-title");
const sectionKicker = document.querySelector("#section-kicker");
const statStrip = document.querySelector("#stat-strip");

const h = (value) =>
  String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");

const normalize = (value) => String(value ?? "").toLowerCase();

const compactNumber = (value) => Intl.NumberFormat("en", { notation: "compact" }).format(value);

function getHashRoute() {
  const hash = window.location.hash.replace(/^#/, "") || "papers";
  const [route, ...rest] = hash.split("/");
  return {
    route: ["papers", "authors", "figures", "reader"].includes(route) ? route : "papers",
    routeParam: decodeURIComponent(rest.join("/")),
  };
}

async function init() {
  const response = await fetch("data/catalog.json");
  const catalog = await response.json();
  catalog.paperById = Object.fromEntries(catalog.papers.map((paper) => [paper.id, paper]));
  catalog.figureById = Object.fromEntries(catalog.figures.map((figure) => [figure.id, figure]));
  catalog.authorById = Object.fromEntries(catalog.authors.map((author) => [author.id, author]));
  catalog.figuresByPaper = catalog.figures.reduce((groups, figure) => {
    groups[figure.paper_id] ||= [];
    groups[figure.paper_id].push(figure);
    return groups;
  }, {});
  state.catalog = catalog;
  state.selectedPaperId = catalog.papers[0]?.id || "";
  state.selectedAuthorId = catalog.authors[0]?.id || "";
  bindEvents();
  applyRoute();
}

function bindEvents() {
  window.addEventListener("hashchange", applyRoute);
  searchInput.addEventListener("input", () => {
    state.query = searchInput.value.trim();
    render();
  });

  app.addEventListener("click", (event) => {
    const target = event.target.closest("[data-action]");
    if (!target) return;
    const action = target.dataset.action;
    const id = target.dataset.id;

    if (action === "select-paper") {
      state.selectedPaperId = id;
      render();
    }
    if (action === "open-reader") {
      window.location.hash = `reader/${encodeURIComponent(id)}`;
    }
    if (action === "open-pdf") {
      const paper = state.catalog.paperById[id];
      window.open(paper.local_pdf_url, "_blank", "noopener");
    }
    if (action === "open-paper-figures") {
      state.figurePaper = id;
      window.location.hash = `figures/${encodeURIComponent(id)}`;
    }
    if (action === "open-figure") {
      openFigureModal(id);
    }
    if (action === "select-author") {
      state.selectedAuthorId = id;
      render();
    }
  });

  app.addEventListener("change", (event) => {
    const control = event.target.closest("[data-control]");
    if (!control) return;
    if (control.dataset.control === "figure-source") state.figureSource = control.value;
    if (control.dataset.control === "figure-author") state.figureAuthor = control.value;
    if (control.dataset.control === "figure-paper") state.figurePaper = control.value;
    render();
  });

  document.querySelector("#figure-modal").addEventListener("click", (event) => {
    const target = event.target.closest("[data-action]");
    if (!target) return;
    if (target.dataset.action === "close-modal") closeFigureModal();
    if (target.dataset.action === "modal-reader") {
      const figure = state.catalog.figureById[state.modalFigureId];
      closeFigureModal();
      window.location.hash = `reader/${encodeURIComponent(figure.paper_id)}`;
    }
    if (target.dataset.action === "modal-open-image") {
      const figure = state.catalog.figureById[state.modalFigureId];
      window.open(figure.image_path, "_blank", "noopener");
    }
  });
}

function applyRoute() {
  const route = getHashRoute();
  state.route = route.route;
  state.routeParam = route.routeParam;
  if (state.route === "reader" && state.routeParam) state.selectedPaperId = state.routeParam;
  if (state.route === "figures" && state.routeParam) state.figurePaper = state.routeParam;
  render();
}

function setHeader(title) {
  sectionTitle.textContent = title;
  sectionKicker.textContent = "CMB Paper Atlas";
  document.body.dataset.route = state.route;
  document.querySelectorAll(".nav-item").forEach((item) => {
    item.classList.toggle("active", item.dataset.route === state.route);
  });
}

function renderStats() {
  const stats = state.catalog.stats;
  statStrip.innerHTML = [
    statChip("Papers", stats.paper_count),
    statChip("Authors", stats.author_count),
    statChip("Figures", stats.figure_count),
  ].join("");
}

function statChip(label, value) {
  return `<span class="stat-chip"><strong>${h(compactNumber(value))}</strong>${h(label)}</span>`;
}

function render() {
  if (!state.catalog) return;
  renderStats();
  if (state.route === "papers") {
    setHeader("Papers");
    app.innerHTML = renderPapersView();
  }
  if (state.route === "authors") {
    setHeader("Authors");
    app.innerHTML = renderAuthorsView();
  }
  if (state.route === "figures") {
    setHeader("Figures");
    app.innerHTML = renderFiguresView();
  }
  if (state.route === "reader") {
    setHeader("Reader");
    app.innerHTML = renderReaderView();
  }
}

function paperSearchText(paper) {
  return normalize([paper.title, paper.arxiv_id, paper.abstract, paper.authors.join(" "), paper.categories.join(" ")].join(" "));
}

function figureSearchText(figure) {
  return normalize([figure.caption, figure.title, figure.arxiv_id, figure.authors.join(" "), figure.keywords.join(" ")].join(" "));
}

function filteredPapers() {
  const query = normalize(state.query);
  let papers = state.catalog.papers;
  if (query) papers = papers.filter((paper) => paperSearchText(paper).includes(query));
  return papers;
}

function filteredAuthors() {
  const query = normalize(state.query);
  let authors = state.catalog.authors;
  if (query) {
    authors = authors.filter((author) => {
      const papers = author.paper_ids.map((id) => state.catalog.paperById[id]).filter(Boolean);
      return normalize([author.name, papers.map((paper) => paper.title).join(" ")].join(" ")).includes(query);
    });
  }
  return authors;
}

function filteredFigures() {
  const query = normalize(state.query);
  let figures = state.catalog.figures;
  if (state.figureSource !== "all") {
    figures = figures.filter((figure) => figure.source_type === state.figureSource);
  }
  if (state.figurePaper !== "all") {
    figures = figures.filter((figure) => figure.paper_id === state.figurePaper);
  }
  if (state.figureAuthor !== "all") {
    const author = state.catalog.authorById[state.figureAuthor];
    const paperIds = new Set(author?.paper_ids || []);
    figures = figures.filter((figure) => paperIds.has(figure.paper_id));
  }
  if (query) figures = figures.filter((figure) => figureSearchText(figure).includes(query));
  return figures;
}

function ensurePaperSelection(papers = state.catalog.papers) {
  if (!state.catalog.paperById[state.selectedPaperId]) state.selectedPaperId = papers[0]?.id || state.catalog.papers[0]?.id || "";
  if (papers.length && !papers.some((paper) => paper.id === state.selectedPaperId)) state.selectedPaperId = papers[0].id;
  return state.catalog.paperById[state.selectedPaperId] || papers[0] || state.catalog.papers[0];
}

function ensureAuthorSelection(authors = state.catalog.authors) {
  if (!state.catalog.authorById[state.selectedAuthorId]) state.selectedAuthorId = authors[0]?.id || state.catalog.authors[0]?.id || "";
  if (authors.length && !authors.some((author) => author.id === state.selectedAuthorId)) state.selectedAuthorId = authors[0].id;
  return state.catalog.authorById[state.selectedAuthorId] || authors[0] || state.catalog.authors[0];
}

function renderPapersView() {
  const papers = filteredPapers();
  const selected = ensurePaperSelection(papers);
  return `
    <div class="view-grid papers-view">
      <section class="panel">
        <div class="panel-head">
          <h2>Papers</h2>
          <span class="muted">${papers.length} results</span>
        </div>
        <div class="paper-list">
          ${papers.map((paper) => paperRow(paper, paper.id === selected?.id)).join("") || emptySmall("No papers")}
        </div>
      </section>
      ${selected ? paperDetailPanel(selected) : emptyPanel("No paper selected")}
      ${selected ? relatedPanel(selected.id, "Related figures") : ""}
    </div>
  `;
}

function paperRow(paper, selected) {
  return `
    <button class="paper-row ${selected ? "selected" : ""}" type="button" data-action="select-paper" data-id="${h(paper.id)}">
      <span class="paper-title">${h(paper.title)}</span>
      <span class="paper-meta">
        <span>${h(authorSummary(paper.authors))}</span>
        <span>${h(paper.arxiv_id)}</span>
        <span>${h(paper.year || "n.d.")}</span>
        <span class="category">${h(paper.primary_category || "arXiv")}</span>
        <span>${paper.figure_count} figures</span>
      </span>
    </button>
  `;
}

function paperDetailPanel(paper) {
  const figures = figuresForPaper(paper.id);
  return `
    <article class="panel paper-detail">
      <div class="panel-head">
        <h2>${h(paper.arxiv_id)}</h2>
        <div class="panel-actions">
          <button class="button secondary" type="button" data-action="open-paper-figures" data-id="${h(paper.id)}">Figures</button>
          <button class="button primary" type="button" data-action="open-reader" data-id="${h(paper.id)}">Reader</button>
        </div>
      </div>
      <div class="detail-scroll">
        <div class="detail-hero">
          <img class="paper-thumb" src="${h(paper.page_thumb)}" alt="" loading="lazy" />
          <div>
            <h2 class="detail-title">${h(paper.title)}</h2>
            <p class="detail-authors">${h(paper.authors.join(", "))}</p>
            <div class="meta-row">
              <span>${h(paper.published.slice(0, 10))}</span>
              <span>${h(paper.primary_category)}</span>
              <span>${paper.page_count || "?"} pages</span>
              <span>${figures.length} figures</span>
            </div>
            <div class="keyword-row">${paper.keywords.slice(0, 8).map((term) => `<span class="keyword-chip">${h(term)}</span>`).join("")}</div>
            <p class="abstract">${h(paper.abstract)}</p>
            <div class="action-row">
              <button class="button primary" type="button" data-action="open-pdf" data-id="${h(paper.id)}">Open PDF</button>
              <a class="button secondary" href="${h(paper.abs_url)}" target="_blank" rel="noopener">arXiv</a>
              ${paper.doi ? `<a class="button secondary" href="https://doi.org/${h(paper.doi)}" target="_blank" rel="noopener">DOI</a>` : ""}
            </div>
          </div>
        </div>
        <section class="detail-section">
          <div class="section-line">
            <h3>Figures in this paper</h3>
            <button class="button secondary" type="button" data-action="open-paper-figures" data-id="${h(paper.id)}">View all</button>
          </div>
          ${figures.length ? `<div class="figure-strip">${figures.slice(0, 18).map((figure) => figureCard(figure)).join("")}</div>` : emptySmall("No figures")}
        </section>
      </div>
    </article>
  `;
}

function renderAuthorsView() {
  const authors = filteredAuthors();
  const selected = ensureAuthorSelection(authors);
  const maxCount = Math.max(...state.catalog.authors.map((author) => author.paper_count), 1);
  return `
    <div class="view-grid authors-view">
      <section class="panel">
        <div class="panel-head">
          <h2>Authors facet</h2>
          <span class="muted">${authors.length} authors</span>
        </div>
        <div class="author-list">
          ${authors.map((author) => authorRow(author, author.id === selected?.id, maxCount)).join("") || emptySmall("No authors")}
        </div>
      </section>
      ${selected ? authorDetailPanel(selected) : emptyPanel("No author selected")}
    </div>
  `;
}

function authorRow(author, selected, maxCount) {
  const pct = Math.max(8, Math.round((author.paper_count / maxCount) * 100));
  return `
    <button class="author-row ${selected ? "selected" : ""}" type="button" data-action="select-author" data-id="${h(author.id)}">
      <span class="author-bar">
        <span class="author-name">${h(author.name)}</span>
        <span class="muted">${author.paper_count}</span>
      </span>
      <span class="count-bar"><span style="width:${pct}%"></span></span>
    </button>
  `;
}

function authorDetailPanel(author) {
  const papers = author.paper_ids.map((id) => state.catalog.paperById[id]).filter(Boolean);
  const paperIds = new Set(author.paper_ids);
  const figures = state.catalog.figures.filter((figure) => paperIds.has(figure.paper_id)).slice(0, 24);
  return `
    <section class="panel">
      <div class="panel-head">
        <h2>${h(author.name)}</h2>
        <span class="muted">${papers.length} papers</span>
      </div>
      <div class="author-detail-grid">
        <div class="mini-paper-list">
          ${papers
            .map(
              (paper) => `
                <article class="mini-paper">
                  <h3 class="paper-title">${h(paper.title)}</h3>
                  <div class="paper-meta">
                    <span>${h(paper.arxiv_id)}</span>
                    <span>${h(paper.year)}</span>
                    <span>${paper.figure_count} figures</span>
                  </div>
                  <div class="action-row">
                    <button class="button primary" type="button" data-action="open-reader" data-id="${h(paper.id)}">Reader</button>
                    <button class="button secondary" type="button" data-action="open-paper-figures" data-id="${h(paper.id)}">Figures</button>
                  </div>
                </article>
              `,
            )
            .join("")}
        </div>
        <aside>
          <div class="panel-head inline-head">
            <h3>Author figures</h3>
            <span class="muted">${figures.length}</span>
          </div>
          <div class="figure-strip author-strip">${figures.map((figure) => figureCard(figure)).join("") || emptySmall("No figures")}</div>
        </aside>
      </div>
    </section>
  `;
}

function renderFiguresView() {
  const figures = filteredFigures();
  return `
    <div class="figures-page">
      <div class="filters">
        <select class="select-control" data-control="figure-source" aria-label="Figure source">
          <option value="all" ${state.figureSource === "all" ? "selected" : ""}>All sources</option>
          <option value="embedded" ${state.figureSource === "embedded" ? "selected" : ""}>Embedded images</option>
          <option value="figure-crop" ${state.figureSource === "figure-crop" ? "selected" : ""}>Figure crops</option>
        </select>
        <select class="select-control" data-control="figure-paper" aria-label="Paper filter">
          <option value="all" ${state.figurePaper === "all" ? "selected" : ""}>All papers</option>
          ${state.catalog.papers.map((paper) => `<option value="${h(paper.id)}" ${state.figurePaper === paper.id ? "selected" : ""}>${h(paper.arxiv_id)} ${h(trimTitle(paper.title, 54))}</option>`).join("")}
        </select>
        <select class="select-control" data-control="figure-author" aria-label="Author filter">
          <option value="all" ${state.figureAuthor === "all" ? "selected" : ""}>All authors</option>
          ${state.catalog.authors.map((author) => `<option value="${h(author.id)}" ${state.figureAuthor === author.id ? "selected" : ""}>${h(author.name)} (${author.paper_count})</option>`).join("")}
        </select>
        <span class="stat-chip figure-count"><strong>${figures.length}</strong>matching figures</span>
      </div>
      <div class="gallery">
        ${figures.map((figure) => figureCard(figure, true)).join("") || emptyPanel("No figures")}
      </div>
    </div>
  `;
}

function renderReaderView() {
  const requested = state.routeParam && state.catalog.paperById[state.routeParam] ? state.catalog.paperById[state.routeParam] : null;
  const paper = requested || state.catalog.paperById[state.selectedPaperId] || state.catalog.papers[0];
  state.selectedPaperId = paper.id;
  return `
    <div class="view-grid reader-view">
      <section class="panel reader-main">
        <header class="reader-header">
          <h2 class="reader-title">${h(paper.title)}</h2>
          <div class="meta-row">
            <span>${h(paper.authors.join(", "))}</span>
            <span>${h(paper.arxiv_id)}</span>
            <span>${h(paper.primary_category)}</span>
          </div>
          <div class="action-row reader-open-actions">
            <button class="button primary" type="button" data-action="open-pdf" data-id="${h(paper.id)}">Open PDF</button>
            <button class="button secondary" type="button" data-action="open-paper-figures" data-id="${h(paper.id)}">All figures</button>
          </div>
        </header>
        ${readerPages(paper)}
      </section>
      <aside class="reader-side">
        ${paperFiguresPanel(paper.id)}
        ${relatedPanel(paper.id, "Related figures")}
      </aside>
    </div>
  `;
}

function readerPages(paper) {
  if (!paper.reader_pages?.length) {
    return `<iframe class="pdf-frame" title="${h(paper.title)}" src="${h(paper.local_pdf_url)}#view=FitH"></iframe>`;
  }
  return `
    <div class="reader-page-scroll" aria-label="Rendered paper pages">
      ${paper.reader_pages
        .map(
          (src, index) => `
            <figure class="reader-page">
              <img src="${h(src)}" alt="${h(`${paper.title}, page ${index + 1}`)}" loading="${index < 2 ? "eager" : "lazy"}" />
              <figcaption>Page ${index + 1}</figcaption>
            </figure>
          `,
        )
        .join("")}
    </div>
  `;
}

function paperFiguresPanel(paperId) {
  const figures = figuresForPaper(paperId);
  return `
    <section class="panel side-panel">
      <div class="panel-head">
        <h3>Figures in this paper</h3>
        <span class="muted">${figures.length}</span>
      </div>
      <div class="side-list">
        ${figures.slice(0, 16).map((figure) => relatedFigureRow(figure)).join("") || emptySmall("No figures")}
      </div>
    </section>
  `;
}

function relatedPanel(paperId, title) {
  const figures = relatedFigures(paperId).slice(0, 12);
  return `
    <aside class="panel side-panel">
      <div class="panel-head">
        <h3>${h(title)}</h3>
        <button class="button secondary" type="button" data-action="open-paper-figures" data-id="${h(paperId)}">Gallery</button>
      </div>
      <div class="side-list">
        ${figures.map((figure) => relatedFigureRow(figure)).join("") || emptySmall("No related figures")}
      </div>
    </aside>
  `;
}

function figureCard(figure, large = false) {
  const typeClass = figure.source_type === "figure-crop" ? "crop" : "";
  return `
    <button class="figure-card ${large ? "large" : ""}" type="button" data-action="open-figure" data-id="${h(figure.id)}">
      <img src="${h(figure.thumb_path)}" alt="${h(figure.caption)}" loading="lazy" />
      <span class="figure-card-body">
        <span class="figure-caption">${h(figure.caption || `Page ${figure.page}`)}</span>
        <span class="paper-meta">
          <span class="type-chip ${typeClass}">${figure.source_type === "figure-crop" ? "crop" : "embedded"}</span>
          <span>p. ${figure.page}</span>
        </span>
        <span class="figure-paper">${h(figure.title)}</span>
      </span>
    </button>
  `;
}

function relatedFigureRow(figure) {
  const typeClass = figure.source_type === "figure-crop" ? "crop" : "";
  return `
    <button class="related-card" type="button" data-action="open-figure" data-id="${h(figure.id)}">
      <img src="${h(figure.thumb_path)}" alt="${h(figure.caption)}" loading="lazy" />
      <span>
        <span class="related-title">${h(figure.caption || figure.title)}</span>
        <span class="related-meta">${h(figure.arxiv_id)} · p. ${figure.page}</span>
        <span class="paper-meta"><span class="type-chip ${typeClass}">${figure.source_type === "figure-crop" ? "crop" : "embedded"}</span></span>
      </span>
    </button>
  `;
}

function relatedFigures(paperId) {
  const paper = state.catalog.paperById[paperId];
  if (!paper) return [];
  const paperKeywords = new Set(paper.keywords || []);
  const authorSet = new Set(paper.author_ids || []);
  return state.catalog.figures
    .filter((figure) => figure.paper_id !== paperId)
    .map((figure) => {
      const otherPaper = state.catalog.paperById[figure.paper_id];
      const otherAuthors = new Set(otherPaper?.author_ids || []);
      const keywordScore = (figure.keywords || []).reduce((score, term) => score + (paperKeywords.has(term) ? 2 : 0), 0);
      const authorScore = [...authorSet].some((author) => otherAuthors.has(author)) ? 8 : 0;
      const categoryScore = otherPaper?.primary_category === paper.primary_category ? 1 : 0;
      const sourceScore = figure.source_type === "figure-crop" ? 0.35 : 0.2;
      return { figure, score: keywordScore + authorScore + categoryScore + sourceScore };
    })
    .sort((a, b) => b.score - a.score)
    .map((item) => item.figure);
}

function figuresForPaper(paperId) {
  return state.catalog.figuresByPaper[paperId] || [];
}

function authorSummary(authors) {
  if (!authors.length) return "Unknown authors";
  if (authors.length <= 3) return authors.join(", ");
  return `${authors.slice(0, 2).join(", ")} et al.`;
}

function trimTitle(title, max = 72) {
  return title.length > max ? `${title.slice(0, max - 1).trim()}...` : title;
}

function emptySmall(label) {
  return `<div class="empty-state small">${h(label)}</div>`;
}

function emptyPanel(label) {
  return `<section class="panel empty-state">${h(label)}</section>`;
}

function openFigureModal(figureId) {
  const figure = state.catalog.figureById[figureId];
  if (!figure) return;
  state.modalFigureId = figureId;
  const paper = state.catalog.paperById[figure.paper_id];
  document.querySelector("#modal-source").textContent = `${figure.arxiv_id} · page ${figure.page}`;
  document.querySelector("#modal-title").textContent = paper?.title || figure.title;
  document.querySelector("#modal-image").src = figure.image_path;
  document.querySelector("#modal-image").alt = figure.caption || figure.title;
  document.querySelector("#modal-caption").textContent = figure.caption || "";
  document.querySelector("#figure-modal").hidden = false;
}

function closeFigureModal() {
  document.querySelector("#figure-modal").hidden = true;
  state.modalFigureId = "";
}

init().catch((error) => {
  console.error(error);
  app.innerHTML = `<div class="empty-state">Could not load catalog.json</div>`;
});
