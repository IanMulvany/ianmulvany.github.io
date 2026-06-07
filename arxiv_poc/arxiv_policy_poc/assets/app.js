const sourceGroups = [
  {
    group: "Author setup",
    summary: "Identity, endorsement, ownership, and proxy submission prerequisites.",
    docs: [
      {
        title: "Author Registration",
        file: "Directions for Author Registration - arXiv info.html",
        summary: "Username, password, archive selection, and email verification requirements.",
        tags: ["author", "account"],
      },
      {
        title: "Identity and Affiliation",
        file: "Identity, affiliation, and registration - arXiv info.html",
        summary: "Current affiliation, one-account policy, name changes, and Code of Conduct linkage.",
        tags: ["author", "policy"],
      },
      {
        title: "The arXiv endorsement system",
        file: "Endorsement - arXiv info.html",
        summary: "Why endorsement exists, how new authors get endorsed, and endorser responsibilities.",
        tags: ["author", "policy"],
      },
      {
        title: "Endorsement saved duplicate",
        file: "Endorsement - arXiv info2.html",
        summary: "Duplicate saved copy with the same content and different captured assets/navigation state.",
        tags: ["duplicate"],
      },
      {
        title: "Authority Records",
        file: "Authority Records - arXiv info.html",
        summary: "Paper ownership, author claims, author status changes, and falsification reports.",
        tags: ["author", "staff"],
      },
      {
        title: "Third party submission",
        file: "Proxy _ Third Party Submission - arXiv info.html",
        summary: "Trusted proxy requirements, prior authorization, SWORD deposits, and daily limits.",
        tags: ["author", "staff", "policy"],
      },
    ],
  },
  {
    group: "Prepare and submit",
    summary: "Source formats, upload flow, metadata, status, and version behavior.",
    docs: [
      {
        title: "Submission Guidelines",
        file: "Submission Overview - arXiv info.html",
        summary: "Main submission workflow, accepted formats, figure formats, file names, upload, preview, and submit.",
        tags: ["author"],
      },
      {
        title: "TeX Submissions",
        file: "Submit TeX_LaTeX - arXiv info.html",
        summary: "TeX processors, automatic processing, figures, style files, bibliography files, indexes, and hidden files.",
        tags: ["author"],
      },
      {
        title: "Submission of PDF",
        file: "Submit a PDF - arXiv info.html",
        summary: "Machine-readable PDF requirements, embedded JavaScript rejection, font guidance, and copyright notices.",
        tags: ["author", "policy"],
      },
      {
        title: "LaTeX Markup Best Practices for Successful HTML Papers",
        file: "LaTeX Markup Best Practices for Successful HTML Papers - arXiv info.html",
        summary: "LaTeXML-friendly packages, accessibility macros, front matter, image alt text, and semantic structure.",
        tags: ["author"],
      },
      {
        title: "Title and Abstract Fields",
        file: "Metadata for Required and Optional Fields - arXiv info.html",
        summary: "Required title, authors, abstract, optional fields, ASCII metadata, comments, DOI, and examples.",
        tags: ["author", "metadata"],
      },
      {
        title: "Submission Status",
        file: "Status Information - arXiv info.html",
        summary: "Incomplete, processing, submitted, on hold, expiration, and ownership dashboard behavior.",
        tags: ["author"],
      },
      {
        title: "Availability of submissions",
        file: "Availability of submissions - arXiv info.html",
        summary: "Announcement timing, arXiv identifier assignment, quality assurance delays, and deferred mailings.",
        tags: ["author"],
      },
      {
        title: "To replace an article",
        file: "Submit a new version of a work - arXiv info.html",
        summary: "Replacement frequency, same-day edits, comments, previous versions, and version 5 mailing behavior.",
        tags: ["author", "version"],
      },
      {
        title: "Submission Version Availability",
        file: "Version Availability - arXiv info.html",
        summary: "Historical version record, citing versions, withdrawals, translations, related works, splitting, and merging.",
        tags: ["author", "policy"],
      },
      {
        title: "Submission of indexes for conference proceedings",
        file: "Submit a Paper List for Conference Proceedings - arXiv info.html",
        summary: "Index submission for conference proceedings before or after individual paper submissions.",
        tags: ["author", "staff"],
      },
    ],
  },
  {
    group: "Policies and enforcement",
    summary: "Moderation, format, license, conduct, privacy, and legal agreement sources.",
    docs: [
      {
        title: "Policies for Format Requirements",
        file: "Policies for Format Requirements - arXiv info.html",
        summary: "Required article format, forbidden format features, and large non-text content guidance.",
        tags: ["policy", "author", "staff"],
      },
      {
        title: "arXiv moderation",
        file: "Content Moderation - arXiv info.html",
        summary: "Reclassification, declined submissions, scholarly standards, AI language tools, rights, appeal, and moderators.",
        tags: ["policy", "staff"],
      },
      {
        title: "arXiv Submittal Agreement",
        file: "Submission terms and agreement - arXiv info.html",
        summary: "Representations, warranties, policy compliance, curation, license grant, indemnity, and governing law.",
        tags: ["legal", "policy"],
      },
      {
        title: "arXiv License Information",
        file: "Licenses - arXiv info.html",
        summary: "How to choose a license, available licenses, irrevocability, metadata CC0, copyright notices, and reuse requests.",
        tags: ["legal", "policy", "author"],
      },
      {
        title: "arXiv Code of Conduct",
        file: "Code of conduct - arXiv info.html",
        summary: "Stewardship, ethics, engagement, respect, reporting contacts, and related policies by role.",
        tags: ["policy"],
      },
      {
        title: "arXiv Code of Conduct Enforcement",
        file: "arXiv Code of Conduct Enforcement - arXiv info.html",
        summary: "Reporting, written warnings, account-level enforcement, submission-level enforcement, and appeals.",
        tags: ["policy", "staff"],
      },
      {
        title: "arXiv Privacy Policy",
        file: "Privacy policy - arXiv info.html",
        summary: "Personal data collection, use, cookies, disclosures, storage, choices, international rights, and contacts.",
        tags: ["legal", "policy"],
      },
    ],
  },
  {
    group: "Organization and governance",
    summary: "Institutional context, advisory groups, members, staff, and moderators.",
    docs: [
      {
        title: "About arXiv",
        file: "About arXiv - arXiv info.html",
        summary: "Curated research-sharing platform overview, services, moderation caveat, and open access mission.",
        tags: ["about"],
      },
      {
        title: "Who We Are",
        file: "Who we are - arXiv info.html",
        summary: "Organizational identity and community context.",
        tags: ["about"],
      },
      {
        title: "arXiv Staff",
        file: "arXiv Staff - arXiv info.html",
        summary: "Staff listing source.",
        tags: ["about"],
      },
      {
        title: "Funding Support",
        file: "Funding - arXiv info.html",
        summary: "Funding and support source.",
        tags: ["about"],
      },
      {
        title: "Our Members",
        file: "Our Members - arXiv info.html",
        summary: "Member consortia and institutional support tiers.",
        tags: ["about"],
      },
      {
        title: "arXiv Governance Model",
        file: "arXiv Governance Model - arXiv info.html",
        summary: "Governance structure source.",
        tags: ["about", "policy"],
      },
      {
        title: "Science Advisory Council",
        file: "Science Advisory Council - arXiv info.html",
        summary: "Science Advisory Council membership source.",
        tags: ["about"],
      },
      {
        title: "Editorial Advisory Council",
        file: "Editorial Advisory Council - arXiv info.html",
        summary: "Editorial Advisory Council and section editorial committees.",
        tags: ["about", "staff"],
      },
      {
        title: "Institutions Advisory Council",
        file: "Institutions Advisory Council - arXiv info.html",
        summary: "Institutions Advisory Council membership source.",
        tags: ["about"],
      },
      {
        title: "Current arXiv moderators",
        file: "arXiv.org.html",
        summary: "Public moderator list by subject area.",
        tags: ["staff", "about"],
      },
    ],
  },
];

const sourceGrid = document.querySelector("#source-grid");
const sourceDetail = document.querySelector("#source-detail");
const sourceHistory = document.querySelector("#source-history");
const searchInput = document.querySelector("#site-search");
const resultCount = document.querySelector("#result-count");

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function classForTag(tag) {
  if (["author", "policy", "staff", "legal"].includes(tag)) {
    return tag;
  }
  return "";
}

function sourceUrl(file) {
  return `source.html?doc=${encodeURIComponent(file)}`;
}

function historyUrl(file) {
  return `source-history.html?doc=${encodeURIComponent(file)}`;
}

function allSourceDocs() {
  return sourceGroups.flatMap((group) =>
    group.docs.map((doc) => ({
      ...doc,
      group: group.group,
      groupSummary: group.summary,
    }))
  );
}

function isPolicyDocument(doc) {
  return (
    doc.group === "Policies and enforcement" ||
    doc.tags.includes("policy") ||
    doc.tags.includes("legal")
  );
}

function committeeForDocument(doc) {
  const title = doc.title.toLowerCase();
  if (title.includes("privacy") || title.includes("license") || title.includes("agreement")) {
    return "Legal and Policy Committee";
  }
  if (title.includes("conduct") || title.includes("moderation") || title.includes("format")) {
    return "Editorial Policy Committee";
  }
  if (title.includes("governance")) {
    return "Governance Committee";
  }
  return "Operations Policy Committee";
}

function versionRecordForDocument(doc) {
  if (!doc || !isPolicyDocument(doc)) return null;

  const committee = committeeForDocument(doc);
  return {
    currentVersion: "v1.0.0-draft",
    status: "Draft current POC",
    committee,
    history: [
      {
        version: "v1.0.0-draft",
        date: "2026-06-05",
        title: "Current POC policy document",
        approvedAt: "Approval pending; no formal meeting recorded in this prototype.",
        committee,
        changeSummary:
          "Restyled the full saved source document inside the POC policy-document system without changing the source policy text.",
        comments:
          "Replace this draft approval metadata with the actual committee meeting, minutes link, and decision record before treating it as official.",
        current: true,
      },
      {
        version: "v0.2.0-draft",
        date: "2026-06-05",
        title: "Full source restyle",
        approvedAt: "Prototype working session; not an official policy approval.",
        committee: "Documentation Redesign Working Group",
        changeSummary:
          "Imported the saved document body, rewrote source links through the POC, and applied shared POC typography and layout styles.",
        comments:
          "Debate/comment fields were added to prove the governance metadata model; real comments should be imported from meeting notes.",
        current: false,
      },
      {
        version: "v0.1.0-source",
        date: "2026-06-03",
        title: "Saved source baseline",
        approvedAt: "No approval meeting metadata available in the saved source file.",
        committee: "Original source owner not captured",
        changeSummary:
          "Baseline record created from the locally saved arXiv source page before POC restructuring.",
        comments:
          "This entry preserves provenance but does not assert any official governance decision.",
        current: false,
      },
    ],
  };
}

function renderSources() {
  if (!sourceGrid) return;

  sourceGrid.innerHTML = sourceGroups
    .map((group, index) => {
      const docs = group.docs
        .map((doc) => {
          const tags = doc.tags
            .map((tag) => `<span class="tag ${classForTag(tag)}">${escapeHtml(tag)}</span>`)
            .join("");
          const searchText = [doc.title, doc.summary, doc.file, doc.tags.join(" "), group.group]
            .join(" ")
            .toLowerCase();

          return `
            <article class="source-item" data-source-item data-source-text="${escapeHtml(searchText)}">
              <div>
                <a class="source-title" href="${sourceUrl(doc.file)}">${escapeHtml(doc.title)}</a>
              </div>
              <p class="source-summary">${escapeHtml(doc.summary)}</p>
              <div class="tag-row" aria-label="Tags">${tags}</div>
            </article>
          `;
        })
        .join("");

      return `
        <details class="source-group" ${index < 2 ? "open" : ""} data-source-group>
          <summary>
            <strong>${escapeHtml(group.group)}</strong>
            <span>${group.docs.length} documents</span>
          </summary>
          <div class="source-list">${docs}</div>
        </details>
      `;
    })
    .join("");
}

function renderSourceDetail() {
  if (!sourceDetail) return;

  const params = new URLSearchParams(window.location.search);
  const requestedFile = params.get("doc");
  const docs = allSourceDocs();
  const doc = docs.find((item) => item.file === requestedFile) || docs[0];
  const sourceDocument = window.sourceDocumentContent?.[doc?.file];
  const versionRecord = versionRecordForDocument(doc);

  if (!doc) {
    sourceDetail.innerHTML = `
      <div class="empty-state">
        <h2>Source not found</h2>
        <p>The requested source document is not part of this prototype index.</p>
        <a class="source-link" href="sources.html">Return to source index</a>
      </div>
    `;
    return;
  }

  document.title = `${doc.title} | arxiv_new source`;
  const tags = doc.tags
    .map((tag) => `<span class="tag ${classForTag(tag)}">${escapeHtml(tag)}</span>`)
    .join("");
  const related = docs
    .filter((item) => item.file !== doc.file && item.group === doc.group)
    .slice(0, 5)
    .map(
      (item) => `
        <li>
          <a href="${sourceUrl(item.file)}">${escapeHtml(item.title)}</a>
          <span>${escapeHtml(item.summary)}</span>
        </li>
      `
    )
    .join("");

  sourceDetail.innerHTML = `
    <div class="source-detail-card">
      <div class="source-detail-kicker">${escapeHtml(doc.group)}</div>
      <h1>${escapeHtml(doc.title)}</h1>
      <p class="source-detail-summary">${escapeHtml(doc.summary)}</p>
      <div class="tag-row source-detail-tags" aria-label="Tags">${tags}</div>

      <dl class="source-meta">
        <div>
          <dt>Saved source file</dt>
          <dd><code>${escapeHtml(doc.file)}</code></dd>
        </div>
        <div>
          <dt>Use group</dt>
          <dd>${escapeHtml(doc.groupSummary)}</dd>
        </div>
        ${
          sourceDocument?.canonical
            ? `
              <div>
                <dt>Canonical source</dt>
                <dd><a href="${escapeHtml(sourceDocument.canonical)}">${escapeHtml(sourceDocument.canonical)}</a></dd>
              </div>
            `
            : ""
        }
        ${
          versionRecord
            ? `
              <div>
                <dt>Current version</dt>
                <dd>
                  <span class="version-badge">${escapeHtml(versionRecord.currentVersion)}</span>
                  <a class="version-history-link" href="${historyUrl(doc.file)}">Version history</a>
                </dd>
              </div>
            `
            : ""
        }
      </dl>

      <div class="source-actions">
        <a class="source-link" href="sources.html">Back to source index</a>
        ${
          versionRecord
            ? `<a class="source-link" href="${historyUrl(doc.file)}">View version history</a>`
            : ""
        }
      </div>
    </div>

    <article class="source-document" data-searchable>
      ${
        sourceDocument?.html
          ? sourceDocument.html
          : `<p>The full saved source body could not be extracted for this document.</p>`
      }
    </article>

    ${
      related
        ? `
          <section class="source-related" aria-labelledby="related-sources-title">
            <h2 id="related-sources-title">Related source documents</h2>
            <ul>${related}</ul>
          </section>
        `
        : ""
    }
  `;
}

function renderSourceHistory() {
  if (!sourceHistory) return;

  const params = new URLSearchParams(window.location.search);
  const requestedFile = params.get("doc");
  const docs = allSourceDocs();
  const doc = docs.find((item) => item.file === requestedFile) || docs[0];
  const versionRecord = versionRecordForDocument(doc);

  if (!doc || !versionRecord) {
    sourceHistory.innerHTML = `
      <div class="empty-state">
        <h2>Version history not available</h2>
        <p>This source document is not currently tracked as a policy document in the POC metadata model.</p>
        <a class="source-link" href="sources.html">Return to source index</a>
      </div>
    `;
    return;
  }

  document.title = `${doc.title} version history | arxiv_new source`;
  const rows = versionRecord.history
    .map(
      (entry) => `
        <article class="version-entry${entry.current ? " current" : ""}" data-searchable>
          <div class="version-entry-header">
            <div>
              <span class="version-badge">${escapeHtml(entry.version)}</span>
              ${entry.current ? '<span class="tag policy">current</span>' : ""}
            </div>
            <time>${escapeHtml(entry.date)}</time>
          </div>
          <h2>${escapeHtml(entry.title)}</h2>
          <dl>
            <div>
              <dt>Meeting approved at</dt>
              <dd>${escapeHtml(entry.approvedAt)}</dd>
            </div>
            <div>
              <dt>Responsible committee</dt>
              <dd>${escapeHtml(entry.committee)}</dd>
            </div>
            <div>
              <dt>Change summary</dt>
              <dd>${escapeHtml(entry.changeSummary)}</dd>
            </div>
            <div>
              <dt>Notes, debates, or comments</dt>
              <dd>${escapeHtml(entry.comments)}</dd>
            </div>
          </dl>
        </article>
      `
    )
    .join("");

  sourceHistory.innerHTML = `
    <div class="source-detail-card version-history-hero">
      <div class="source-detail-kicker">${escapeHtml(versionRecord.committee)}</div>
      <h1>${escapeHtml(doc.title)} Version History</h1>
      <p class="source-detail-summary">
        Prototype governance record for this policy document. Approval fields are intentionally explicit so real meeting records, committee decisions, and discussion notes can replace draft placeholders.
      </p>
      <dl class="source-meta">
        <div>
          <dt>Current version</dt>
          <dd><span class="version-badge">${escapeHtml(versionRecord.currentVersion)}</span></dd>
        </div>
        <div>
          <dt>Status</dt>
          <dd>${escapeHtml(versionRecord.status)}</dd>
        </div>
        <div>
          <dt>Policy document</dt>
          <dd><a href="${sourceUrl(doc.file)}">${escapeHtml(doc.title)}</a></dd>
        </div>
        <div>
          <dt>Saved source file</dt>
          <dd><code>${escapeHtml(doc.file)}</code></dd>
        </div>
      </dl>
      <div class="source-actions">
        <a class="source-link" href="${sourceUrl(doc.file)}">Back to policy document</a>
        <a class="source-link" href="sources.html">Source index</a>
      </div>
    </div>
    <div class="version-timeline" aria-label="Version history entries">
      ${rows}
    </div>
  `;
}

function searchableText(element) {
  return element.textContent.toLowerCase();
}

function applySearch() {
  if (!searchInput) return;

  const query = searchInput.value.trim().toLowerCase();
  const regularItems = [...document.querySelectorAll("[data-searchable]")].filter(
    (item) => !item.matches("[data-source-item]")
  );

  let visibleRegular = 0;
  regularItems.forEach((item) => {
    const visible = !query || searchableText(item).includes(query);
    item.classList.toggle("is-hidden", !visible);
    if (visible) visibleRegular += 1;
  });

  let visibleSources = 0;
  document.querySelectorAll("[data-source-group]").forEach((group) => {
    let groupVisible = 0;
    group.querySelectorAll("[data-source-item]").forEach((item) => {
      const visible = !query || item.dataset.sourceText.includes(query);
      item.classList.toggle("is-hidden", !visible);
      if (visible) {
        groupVisible += 1;
        visibleSources += 1;
      }
    });
    group.classList.toggle("is-hidden", query && groupVisible === 0);
    if (query && groupVisible > 0) group.open = true;
  });

  if (!query) {
    if (resultCount) resultCount.textContent = "";
    return;
  }

  const total = visibleRegular + visibleSources;
  if (resultCount) {
    resultCount.textContent = `${total} result${total === 1 ? "" : "s"} for "${query}"`;
  }
}

function setupSourceExpansion() {
  const button = document.querySelector("#expand-sources");
  if (!button) return;

  button.addEventListener("click", () => {
    const groups = [...document.querySelectorAll("[data-source-group]")];
    const shouldOpen = groups.some((group) => !group.open);
    groups.forEach((group) => {
      group.open = shouldOpen;
    });
    button.textContent = shouldOpen ? "Collapse all" : "Expand all";
  });
}

function setupKeyboardSearch() {
  if (!searchInput) return;

  window.addEventListener("keydown", (event) => {
    if (event.key === "/" && document.activeElement !== searchInput) {
      event.preventDefault();
      searchInput.focus();
    }
    if (event.key === "Escape" && document.activeElement === searchInput) {
      searchInput.value = "";
      applySearch();
      searchInput.blur();
    }
  });
}

function setupActiveNav() {
  const links = [...document.querySelectorAll(".sidebar a")].filter((link) =>
    link.getAttribute("href")?.startsWith("#")
  );
  const sections = links
    .map((link) => document.querySelector(link.getAttribute("href")))
    .filter(Boolean);

  if (!("IntersectionObserver" in window)) {
    const firstLink = links[0];
    if (firstLink) firstLink.classList.add("active");
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      const visible = entries
        .filter((entry) => entry.isIntersecting)
        .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];

      if (!visible) return;

      links.forEach((link) => {
        link.classList.toggle("active", link.getAttribute("href") === `#${visible.target.id}`);
      });
    },
    {
      rootMargin: "-120px 0px -58% 0px",
      threshold: [0.05, 0.2, 0.45],
    }
  );

  sections.forEach((section) => observer.observe(section));
}

renderSources();
renderSourceDetail();
renderSourceHistory();
setupSourceExpansion();
setupKeyboardSearch();
setupActiveNav();
if (searchInput) searchInput.addEventListener("input", applySearch);
