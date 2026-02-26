/* ── Main application ──────────────────────────────────────── */

const COLORS = {
  positive: "#27ae60",
  neutral:  "#3498db",
  negative: "#e74c3c",
  bug:      "#f39c12",
  agents: ["#3498db","#2ecc71","#e74c3c","#f39c12","#9b59b6","#1abc9c"],
  ratings: ["#27ae60","#2ecc71","#f1c40f","#e74c3c","#bdc3c7"],
};

const AGENT_LABELS = {
  novelty: "Novelty",
  scope: "Scope",
  ethics: "Ethics",
  methodology_reporting: "Methodology Reporting",
  methodology_validation: "Methodology Validation",
  integrity: "Integrity",
};

let DATA = null;
let FEEDBACK_IM = null;
let FEEDBACK_NN = null;
let FEEDBACK_JW = null;
let FEEDBACK_HM = null;
let chartDisagreements = null;

Chart.defaults.font.family = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif";
Chart.defaults.font.size = 12;
Chart.defaults.plugins.legend.labels.usePointStyle = true;
Chart.defaults.plugins.legend.labels.pointStyleWidth = 10;

/* ── Navigation ───────────────────────────────────────────── */
document.querySelectorAll(".nav-link").forEach(link => {
  link.addEventListener("click", e => {
    if (link.target === "_blank" || !link.dataset.view) return;
    e.preventDefault();
    document.querySelectorAll(".nav-link").forEach(l => l.classList.remove("active"));
    link.classList.add("active");
    const view = link.dataset.view;
    document.querySelectorAll(".view").forEach(v => v.classList.remove("active"));
    document.getElementById("view-" + view).classList.add("active");
  });
});

/* ── Data loading ─────────────────────────────────────────── */
async function loadData() {
  const res = await fetch("./data/labelling_analysis_results.json");
  DATA = await res.json();

  const imRes = await fetch("./data/csv_curator_labels_im.json");
  FEEDBACK_IM = await imRes.json();
  const nnRes = await fetch("./data/csv_curator_labels_nn.json");
  FEEDBACK_NN = await nnRes.json();
  try {
    const jwRes = await fetch("./data/csv_curator_labels_jw.json");
    if (jwRes.ok) FEEDBACK_JW = await jwRes.json();
  } catch (_) { FEEDBACK_JW = []; }
  try {
    const hmRes = await fetch("./data/csv_curator_labels_hm.json");
    if (hmRes.ok) FEEDBACK_HM = await hmRes.json();
  } catch (_) { FEEDBACK_HM = []; }

  renderAll();
}

/* ── Render all views ─────────────────────────────────────── */
function renderAll() {
  renderDashboard();
  renderAgents();
  renderNegative();
  renderBacklog();
  renderPositive();
  renderBugs();
  renderPrompts();
  renderIMDeepDive();
  renderNNDeepDive();
  renderJWDeepDive();
  renderHMDeepDive();
}

/* ── 1. Dashboard ─────────────────────────────────────────── */
function renderDashboard() {
  const ia = DATA.inter_annotator;
  const cd = DATA.consensus_distribution;
  document.getElementById("stat-total").textContent = ia.total_items;
  document.getElementById("stat-agreement").textContent = ia.agreement_pct + "%";
  document.getElementById("stat-positive").textContent = cd.positive || 0;
  document.getElementById("stat-negative").textContent = cd.negative || 0;

  // Consensus donut
  new Chart(document.getElementById("chart-consensus"), {
    type: "doughnut",
    data: {
      labels: ["Positive","Neutral","Negative","Bug"],
      datasets: [{
        data: [cd.positive||0, cd.neutral||0, cd.negative||0, cd.bug||0],
        backgroundColor: [COLORS.positive, COLORS.neutral, COLORS.negative, COLORS.bug],
      }]
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } } }
  });

  // Annotator comparison (IM, NN, + overlap annotators)
  const sentiments = ["positive","neutral","negative","bug"];
  const overlapAnnotators = DATA.inter_annotator?.overlap_annotators || [];
  const overlapColors = { jw: "rgba(46,204,113,.7)", hm: "rgba(155,89,182,.7)" };
  const datasets = [
    { label: "IM", data: sentiments.map(s => ia.im_distribution[s]||0),
      backgroundColor: "rgba(52,152,219,.7)" },
    { label: "NN", data: sentiments.map(s => ia.nn_distribution[s]||0),
      backgroundColor: "rgba(231,76,60,.7)" },
  ];
  overlapAnnotators.forEach(a => {
    const dist = DATA.inter_annotator?.[`${a}_distribution`] ||
      DATA.data_sources?.extra_annotator_distributions?.[a] || {};
    if (Object.keys(dist).length) {
      datasets.push({ label: a.toUpperCase(),
        data: sentiments.map(s => dist[s]||0),
        backgroundColor: overlapColors[a] || "rgba(149,165,166,.7)" });
    }
  });
  new Chart(document.getElementById("chart-annotator-compare"), {
    type: "bar",
    data: {
      labels: sentiments.map(s => s.charAt(0).toUpperCase() + s.slice(1)),
      datasets,
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
      scales: { y: { beginAtZero: true } } }
  });

  // Disagreement chart (selectable annotator pair)
  function getAnnotatorData(key) {
    const map = { im: FEEDBACK_IM, nn: FEEDBACK_NN, jw: FEEDBACK_JW, hm: FEEDBACK_HM };
    return (map[key] || []);
  }

  function computeDisagreements(keyA, keyB) {
    const dataA = getAnnotatorData(keyA);
    const dataB = getAnnotatorData(keyB);
    const indexA = Object.fromEntries(dataA.map(i => [i.item_id, i]));
    const indexB = Object.fromEntries(dataB.map(i => [i.item_id, i]));
    const disagree = {};
    let overlap = 0;
    let agree = 0;
    for (const iid of Object.keys(indexA)) {
      const b = indexB[iid];
      if (!b) continue;
      overlap++;
      const sentA = indexA[iid].sentiment_label;
      const sentB = b.sentiment_label;
      if (sentA === sentB) {
        agree++;
      } else if (sentA && sentB) {
        const k = `${sentA}->${sentB}`;
        disagree[k] = (disagree[k] || 0) + 1;
      }
    }
    return { disagree, overlap, agree };
  }

  function renderDisagreementChart() {
    const keyA = document.getElementById("disagree-annotator-a").value;
    const keyB = document.getElementById("disagree-annotator-b").value;
    if (keyA === keyB) return;
    const { disagree, overlap, agree } = computeDisagreements(keyA, keyB);
    const dLabels = Object.keys(disagree).sort((a, b) => disagree[b] - disagree[a]);
    const labels = { im: "IM", nn: "NN", jw: "JW", hm: "HM" };
    const title = `Disagreement Patterns (${labels[keyA] || keyA} → ${labels[keyB] || keyB})`;
    if (chartDisagreements) chartDisagreements.destroy();
    chartDisagreements = new Chart(document.getElementById("chart-disagreements"), {
      type: "bar",
      data: {
        labels: dLabels.length ? dLabels : ["No disagreements"],
        datasets: [{
          label: "Disagreements",
          data: dLabels.length ? dLabels.map(k => disagree[k]) : [0],
          backgroundColor: "rgba(155,89,182,.7)",
        }]
      },
      options: {
        responsive: true, maintainAspectRatio: false, indexAxis: "y",
        plugins: {
          legend: { display: false },
          title: { display: true, text: `${overlap} overlap, ${agree} agree, ${overlap - agree} disagree` }
        },
        scales: { x: { beginAtZero: true } }
      }
    });
  }

  renderDisagreementChart();
  document.getElementById("disagree-annotator-a").addEventListener("change", () => {
    const a = document.getElementById("disagree-annotator-a").value;
    const bSelect = document.getElementById("disagree-annotator-b");
    if (bSelect.value === a) {
      bSelect.value = ["im","nn","jw","hm"].find(v => v !== a) || "nn";
    }
    renderDisagreementChart();
  });
  document.getElementById("disagree-annotator-b").addEventListener("change", () => {
    const b = document.getElementById("disagree-annotator-b").value;
    const aSelect = document.getElementById("disagree-annotator-a");
    if (aSelect.value === b) {
      aSelect.value = ["im","nn","jw","hm"].find(v => v !== b) || "im";
    }
    renderDisagreementChart();
  });
}

/* ── 2. Agent Ranking ─────────────────────────────────────── */
function renderAgents() {
  const ranking = DATA.agent_helpfulness_ranking;

  // Horizontal bar: avg score
  new Chart(document.getElementById("chart-agent-rank"), {
    type: "bar",
    data: {
      labels: ranking.map(r => AGENT_LABELS[r.agent] || r.agent),
      datasets: [{
        label: "Avg Helpfulness",
        data: ranking.map(r => r.avg_score),
        backgroundColor: ranking.map((_, i) =>
          COLORS.agents[i % COLORS.agents.length]),
      }]
    },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: "y",
      plugins: { legend: { display: false } },
      scales: { x: { min: 0, max: 4, title: { display: true, text: "Score (1-4)" } } } }
  });

  // Stacked bar: rating distribution
  const agents = ranking.map(r => r.agent);
  const ratingLabels = ["Very helpful","Moderately helpful","Slightly helpful","Not at all helpful","N/A"];
  const ratingDatasets = ratingLabels.map((label, i) => {
    // Count from raw feedback data
    const counts = agents.map(agent => {
      let count = 0;
      FEEDBACK_IM.forEach(item => {
        if (item.agent_ratings && item.agent_ratings[agent] === label) count++;
      });
      return count;
    });
    return { label, data: counts, backgroundColor: COLORS.ratings[i] };
  });

  new Chart(document.getElementById("chart-rating-dist"), {
    type: "bar",
    data: {
      labels: agents.map(a => AGENT_LABELS[a] || a),
      datasets: ratingDatasets,
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
      scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true } } }
  });

  // Grouped bar: sentiment per agent
  const agentSent = DATA.agent_sentiment;
  const sentKeys = ["positive","neutral","negative","bug"];
  new Chart(document.getElementById("chart-agent-sentiment"), {
    type: "bar",
    data: {
      labels: Object.keys(agentSent).map(a => AGENT_LABELS[a] || a),
      datasets: sentKeys.map(s => ({
        label: s.charAt(0).toUpperCase() + s.slice(1),
        data: Object.keys(agentSent).map(a => agentSent[a][s] || 0),
        backgroundColor: COLORS[s],
      })),
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
      scales: { y: { beginAtZero: true } } }
  });
}

/* ── 3. Negative Analysis ─────────────────────────────────── */
function renderNegative() {
  const neg = DATA.negative_analysis;
  document.getElementById("stat-neg-total").textContent = neg.total;
  document.getElementById("stat-research-flaw").textContent = neg.research_flaw_count;
  document.getElementById("stat-prompt-ctx").textContent = neg.prompt_context_count;
  document.getElementById("stat-eng-change").textContent = neg.categories.engineering_change || 0;

  // Category donut
  const cats = neg.categories;
  const catLabels = Object.keys(cats);
  const catDisplay = {
    engineering_change: "Engineering Change",
    prompt_context_improvement: "Prompt/Context",
    research_flaw: "Research Flaw",
    other: "Other",
  };
  new Chart(document.getElementById("chart-neg-cats"), {
    type: "doughnut",
    data: {
      labels: catLabels.map(c => catDisplay[c] || c),
      datasets: [{ data: catLabels.map(c => cats[c]),
        backgroundColor: ["#3498db","#9b59b6","#e74c3c","#95a5a6"] }],
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } } }
  });

  // Negative by agent
  const agentSent = DATA.agent_sentiment;
  const agentNames = Object.keys(agentSent);
  new Chart(document.getElementById("chart-neg-agents"), {
    type: "bar",
    data: {
      labels: agentNames.map(a => AGENT_LABELS[a] || a),
      datasets: [{ label: "Negative feedback",
        data: agentNames.map(a => agentSent[a].negative || 0),
        backgroundColor: "rgba(231,76,60,.7)" }],
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true } } }
  });

  renderNegativeCategoryDrilldown();
}

function categoriseFeedback(text) {
  const t = (text || "").toLowerCase();
  const cats = [];
  const RESEARCH_FLAW_KW = ["inaccurat","wrong","incorrect","missed","not relevant","irrelevant","hallucin","fabricat","made up","not correct","error in","factual","misidentif","false","didn't identify","failed to identify","not accurate","misunderst"];
  const PROMPT_CONTEXT_KW = ["context","prompt","instruction","didn't understand","misinterpret","scope","out of scope","not what I asked","confused","unclear","ambiguous","too generic","generic","not specific","vague","superficial","shallow","depth","detail","nuance"];
  if (RESEARCH_FLAW_KW.some(kw => t.includes(kw))) cats.push("research_flaw");
  if (PROMPT_CONTEXT_KW.some(kw => t.includes(kw))) cats.push("prompt_context_improvement");
  if (!cats.length) cats.push("other");
  return cats;
}

function getNegativeItemsWithCategories() {
  const nnIndex = {};
  (FEEDBACK_NN || []).forEach(item => { nnIndex[item.item_id] = item; });
  const SEVERITY = {bug:0, negative:1, neutral:2, positive:3};
  const negFromIM = (FEEDBACK_IM || []).filter(item => {
    const nn = nnIndex[item.item_id];
    const imS = item.sentiment_label;
    const nnS = nn ? nn.sentiment_label : imS;
    const cons = imS === nnS ? imS : (SEVERITY[imS] < SEVERITY[nnS] ? imS : nnS);
    return cons === "negative";
  });
  const negFromJW = (FEEDBACK_JW || []).filter(i => i.sentiment_label === "negative")
    .map(i => ({ ...i, _source: "jw" }));
  const allNeg = [...negFromIM.map(i => ({ ...i, _source: "im_nn" })), ...negFromJW];
  return allNeg.map(item => {
    const nn = nnIndex[item.item_id];
    const agents = (nn && nn.related_agents_label && nn.related_agents_label.length)
      ? nn.related_agents_label : (item.related_agents_label || []);
    const cats = categoriseFeedback(item.feedback_text);
    return { ...item, agents, categories: cats };
  });
}

function renderNegativeCategoryDrilldown() {
  const neg = DATA.negative_analysis;
  const researchItems = neg.research_flaw_items || [];
  const promptItems = neg.prompt_context_items || [];
  const useApiData = researchItems.length > 0 || promptItems.length > 0;

  let researchFlawItems = researchItems;
  let promptCtxItems = promptItems;

  if (!useApiData) {
    const allNeg = getNegativeItemsWithCategories();
    researchFlawItems = allNeg.filter(n => n.categories.includes("research_flaw"));
    promptCtxItems = allNeg.filter(n => n.categories.includes("prompt_context_improvement"));
  }

  const renderItem = (item) => {
    const agents = item.agents || [];
    const agentStr = agents.length ? agents.map(a => AGENT_LABELS[a] || a).join(", ") : "General";
    return `<div class="feedback-item">
      <div class="meta">${item.item_id} &middot; Agents: ${agentStr}${item.question_type ? " &middot; " + item.question_type : ""}</div>
      <div class="text">${escHtml(item.feedback_text || "")}</div>
    </div>`;
  };

  const researchEl = document.getElementById("neg-research-flaw-items");
  const promptEl = document.getElementById("neg-prompt-ctx-items");
  const researchBlock = document.getElementById("neg-research-flaw-block");
  const promptBlock = document.getElementById("neg-prompt-ctx-block");

  if (researchEl) {
    researchEl.innerHTML = researchFlawItems.length
      ? researchFlawItems.map(renderItem).join("")
      : "<p class='empty-hint'>No items classified as Research Flaw.</p>";
    if (researchBlock) {
      const title = researchBlock.querySelector(".neg-category-title");
      if (title) title.textContent = `Research Flaw Items (${researchFlawItems.length})`;
    }
  }
  if (promptEl) {
    promptEl.innerHTML = promptCtxItems.length
      ? promptCtxItems.map(renderItem).join("")
      : "<p class='empty-hint'>No items classified as Prompt/Context.</p>";
    if (promptBlock) {
      const title = promptBlock.querySelector(".neg-category-title");
      if (title) title.textContent = `Prompt/Context Issues (${promptCtxItems.length})`;
    }
  }
}

/* ── 4. Product Backlog ───────────────────────────────────── */
function renderBacklog() {
  const bl = DATA.engineering_backlog;
  const subcats = bl.subcategories;
  const order = bl.priority_order;

  const subDisplay = {
    format_length: "Format & Length",
    integration_workflow: "Integration & Workflow",
    duplication_redundancy: "Duplication & Redundancy",
    depth_detail: "Depth & Detail",
    summary_key_points: "Summary & Key Points",
    references_citations: "References & Citations",
    performance: "Performance",
    other_engineering: "Other",
  };
  const subDesc = {
    format_length: "Improve output formatting: allow configurable length, use bullet points, better structure with headings. Many users found agent output overwhelming and hard to scan.",
    integration_workflow: "Better workflow integration: export to PDF/Word, reviewer-friendly navigation, UI improvements. Editors want the tool to fit into their existing review process.",
    duplication_redundancy: "Reduce repetition across agents, deduplicate overlapping findings. Multiple agents often flag the same issue in different ways.",
    depth_detail: "Increase depth and specificity of agent analysis, provide more actionable detail. Some feedback called analysis 'superficial' or 'shallow'.",
    summary_key_points: "Add executive summary / key findings section at the top of each agent report. Editors want a quick overview before diving into details.",
    references_citations: "Improve citation linking, provide direct references to manuscript sections. Make it easy to verify agent claims against the source.",
    performance: "Improve agent response times, add progress indicators, handle timeouts gracefully.",
    other_engineering: "Miscellaneous engineering feedback that doesn't fit the above categories.",
  };

  new Chart(document.getElementById("chart-backlog"), {
    type: "bar",
    data: {
      labels: order.map(s => subDisplay[s] || s),
      datasets: [{ label: "Feedback items",
        data: order.map(s => subcats[s]),
        backgroundColor: order.map((_, i) => COLORS.agents[i % COLORS.agents.length]),
      }],
    },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: "y",
      plugins: { legend: { display: false } },
      scales: { x: { beginAtZero: true } } }
  });

  const container = document.getElementById("backlog-cards");
  container.innerHTML = order.map((subcat, i) => `
    <div class="backlog-card">
      <span class="priority">P${i+1}</span>
      <span class="count">${subcats[subcat]} feedback items</span>
      <h4>${subDisplay[subcat] || subcat}</h4>
      <p>${subDesc[subcat] || ""}</p>
    </div>
  `).join("");
}

/* ── 5. Positive Feedback ─────────────────────────────────── */
function renderPositive() {
  const pos = DATA.positive_analysis;
  document.getElementById("stat-pos-total").textContent = pos.total;

  const themeDisplay = {
    useful_insights: "Useful Insights",
    agrees_with_reviewer: "Agrees with Reviewer",
    effective_identification: "Effective Identification",
    time_saving: "Time Saving",
    thorough_analysis: "Thorough Analysis",
    educational: "Educational",
    other_positive: "Other",
  };

  const themes = pos.themes;
  const tKeys = Object.keys(themes).sort((a,b) => themes[b] - themes[a]);
  new Chart(document.getElementById("chart-pos-themes"), {
    type: "doughnut",
    data: {
      labels: tKeys.map(t => themeDisplay[t] || t),
      datasets: [{ data: tKeys.map(t => themes[t]),
        backgroundColor: ["#27ae60","#2ecc71","#1abc9c","#3498db","#2980b9","#f39c12","#95a5a6"],
      }],
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } } }
  });

  // Positive by agent
  const agentSent = DATA.agent_sentiment;
  const agentNames = Object.keys(agentSent);
  new Chart(document.getElementById("chart-pos-agents"), {
    type: "bar",
    data: {
      labels: agentNames.map(a => AGENT_LABELS[a] || a),
      datasets: [{ label: "Positive feedback",
        data: agentNames.map(a => agentSent[a].positive || 0),
        backgroundColor: "rgba(39,174,96,.7)" }],
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true } } }
  });
}

/* ── 6. Bug Reports ───────────────────────────────────────── */
function renderBugs() {
  const bugs = DATA.bug_analysis;
  document.getElementById("stat-bug-total").textContent = bugs.total;

  const byAgent = bugs.by_agent;
  const agentKeys = Object.keys(byAgent).sort((a,b) => byAgent[b] - byAgent[a]);
  new Chart(document.getElementById("chart-bugs"), {
    type: "bar",
    data: {
      labels: agentKeys.map(a => AGENT_LABELS[a] || a),
      datasets: [{ label: "Bug reports",
        data: agentKeys.map(a => byAgent[a]),
        backgroundColor: "rgba(243,156,18,.7)" }],
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true } } }
  });
}

/* ── 7. Prompt Improvements ───────────────────────────────── */
function renderPrompts() {
  const container = document.getElementById("prompt-cards");
  container.innerHTML = PROMPT_SUGGESTIONS.map(agent => {
    const scoreClass = agent.avg_score < 2.0 ? "score-low" :
                       agent.avg_score < 3.0 ? "score-mid" : "score-high";
    return `
    <div class="prompt-card">
      <div class="agent-header">
        <span class="agent-name">${AGENT_LABELS[agent.agent] || agent.agent}</span>
        <span class="score-badge ${scoreClass}">Avg score: ${agent.avg_score.toFixed(2)} &middot; +${agent.positive_count} / -${agent.negative_count}</span>
      </div>
      <p style="margin-bottom:12px;font-size:.9rem;line-height:1.5">${agent.summary}</p>

      <h4>Issues Identified from Feedback</h4>
      <ul class="issue-list">
        ${agent.issues.map(issue => `<li>${escHtml(issue)}</li>`).join("")}
      </ul>

      <h4>Suggested Prompt Additions</h4>
      <ol class="prompt-list">
        ${agent.prompts.map(p => `
          <li>${escHtml(p.text)}</li>
          <div class="rationale">${escHtml(p.rationale)}</div>
        `).join("")}
      </ol>
    </div>`;
  }).join("");
}

/* ── 8. IM / NN Deep Dive (shared logic for CSV-based annotators) ── */
function renderAnnotatorDeepDive(key, label, color) {
  const dataMap = { im: FEEDBACK_IM, nn: FEEDBACK_NN, hm: FEEDBACK_HM };
  const data = dataMap[key] || [];
  const items = data || [];
  const container = document.getElementById(`view-${key}-deep-dive`);
  if (!items.length) {
    container.querySelector(".stats-row").innerHTML =
      `<p style='grid-column:1/-1;color:var(--text-light)'>${label} data not loaded.</p>`;
    return;
  }

  const labeled = items.filter(i => i.sentiment_label != null);
  const unlabeled = items.filter(i => i.sentiment_label == null);
  const questionCounts = {};
  const questionTypeCounts = {};
  const ratingCounts = {};
  const sentimentByAgent = {};

  items.forEach(item => {
    const q = (item.question || "Unknown").slice(0, 55);
    questionCounts[q] = (questionCounts[q] || 0) + 1;
    const qt = item.question_type || "unknown";
    questionTypeCounts[qt] = (questionTypeCounts[qt] || 0) + 1;

    const ratings = item.agent_ratings || {};
    Object.entries(ratings).forEach(([agent, r]) => {
      ratingCounts[agent] = ratingCounts[agent] || {};
      ratingCounts[agent][r] = (ratingCounts[agent][r] || 0) + 1;
    });

    const agents = item.related_agents_label || [];
    const sent = item.sentiment_label;
    if (sent && agents.length) {
      agents.forEach(a => {
        sentimentByAgent[a] = sentimentByAgent[a] || {};
        sentimentByAgent[a][sent] = (sentimentByAgent[a][sent] || 0) + 1;
      });
    }
  });

  document.getElementById(`stat-${key}-total`).textContent = items.length;
  document.getElementById(`stat-${key}-labeled`).textContent = labeled.length;
  document.getElementById(`stat-${key}-unlabeled`).textContent = unlabeled.length;
  document.getElementById(`stat-${key}-questions`).textContent =
    Object.keys(questionCounts).length;

  // Sentiment donut
  const sentCounts = { positive: 0, neutral: 0, negative: 0, bug: 0 };
  labeled.forEach(i => { sentCounts[i.sentiment_label] = (sentCounts[i.sentiment_label] || 0) + 1; });
  let sentLabels = Object.keys(sentCounts).filter(s => sentCounts[s] > 0);
  let sentData = sentLabels.map(s => sentCounts[s]);
  let sentColors = sentLabels.map(s => COLORS[s]);
  if (sentLabels.length === 0) {
    sentLabels = ["No labeled items"];
    sentData = [1];
    sentColors = ["#bdc3c7"];
  }
  new Chart(document.getElementById(`chart-${key}-sentiment`), {
    type: "doughnut",
    data: {
      labels: sentLabels.map(s => s.charAt(0).toUpperCase() + s.slice(1)),
      datasets: [{ data: sentData, backgroundColor: sentColors }]
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } }
    }
  });

  // Question types
  const qtEntries = Object.entries(questionTypeCounts).sort((a, b) => b[1] - a[1]);
  new Chart(document.getElementById(`chart-${key}-question-types`), {
    type: "bar",
    data: {
      labels: qtEntries.map(([q]) => q.length > 30 ? q.slice(0, 27) + "…" : q),
      datasets: [{ label: "Items", data: qtEntries.map(([, c]) => c),
        backgroundColor: color }]
    },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: "y",
      plugins: { legend: { display: false } },
      scales: { x: { beginAtZero: true } } }
  });

  // Agent ratings (stacked: Very helpful, Moderately, etc per agent)
  const RATING_ORDER = ["Very helpful", "Moderately helpful", "Slightly helpful", "Not at all helpful", "N/A"];
  const AGENT_ORDER = ["novelty", "scope", "ethics", "methodology_reporting", "methodology_validation", "integrity"];
  const agents = AGENT_ORDER.filter(a => ratingCounts[a]);
  const ratingDatasets = RATING_ORDER.map((r, i) => ({
    label: r,
    data: agents.map(a => ratingCounts[a][r] || 0),
    backgroundColor: COLORS.ratings[i]
  }));
  new Chart(document.getElementById(`chart-${key}-agent-ratings`), {
    type: "bar",
    data: {
      labels: agents.map(a => AGENT_LABELS[a] || a),
      datasets: ratingDatasets,
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
      scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true } } }
  });

  // Sentiment by related agent
  let agentSentEntries = Object.entries(sentimentByAgent)
    .map(([a, s]) => ({ agent: a, positive: s.positive || 0, neutral: s.neutral || 0, negative: s.negative || 0, bug: s.bug || 0 }))
    .sort((a, b) => (b.positive + b.negative + b.neutral + b.bug) - (a.positive + a.negative + a.neutral + a.bug));
  if (agentSentEntries.length === 0) {
    agentSentEntries = [{ agent: "novelty", positive: 0, neutral: 0, negative: 0, bug: 0 }];
  }
  const sentKeys = ["positive", "neutral", "negative", "bug"];
  new Chart(document.getElementById(`chart-${key}-sentiment-by-agent`), {
    type: "bar",
    data: {
      labels: agentSentEntries.map(e => AGENT_LABELS[e.agent] || e.agent),
      datasets: sentKeys.map(s => ({
        label: s.charAt(0).toUpperCase() + s.slice(1),
        data: agentSentEntries.map(e => e[s] || 0),
        backgroundColor: COLORS[s],
      })),
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
      scales: { y: { stacked: true, beginAtZero: true } } }
  });

  // Questions bar
  const qEntries = Object.entries(questionCounts).sort((a, b) => b[1] - a[1]);
  new Chart(document.getElementById(`chart-${key}-questions`), {
    type: "bar",
    data: {
      labels: qEntries.map(([q]) => q.length > 45 ? q.slice(0, 42) + "…" : q),
      datasets: [{ label: "Items", data: qEntries.map(([, c]) => c),
        backgroundColor: color }]
    },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: "y",
      plugins: { legend: { display: false } },
      scales: { x: { beginAtZero: true } } }
  });

  // Sample feedback
  const samples = items.filter(i => (i.feedback_text || "").trim().length > 20).slice(0, 25);
  const samplesEl = document.getElementById(`${key}-feedback-samples`);
  samplesEl.innerHTML = `<h3>Sample ${label} Feedback (first 25 with substantial text)</h3>` +
    samples.map(item => {
      const sentTag = item.sentiment_label
        ? `<span class="tag ${item.sentiment_label}">${item.sentiment_label}</span>`
        : "<span class=\"tag\" style=\"background:#ecf0f1;color:#7f8c8d\">unlabeled</span>";
      const agentsStr = (item.related_agents_label || []).length
        ? (item.related_agents_label || []).map(a => AGENT_LABELS[a] || a).join(", ")
        : "General";
      return `<div class="feedback-item">
        <div class="meta">${item.item_id} &middot; ${item.question_type || "—"} &middot; ${agentsStr} &middot; ${sentTag}</div>
        <div class="text">${escHtml(item.feedback_text || "")}</div>
      </div>`;
    }).join("");
}

function renderIMDeepDive() {
  renderAnnotatorDeepDive("im", "IM", "rgba(52,152,219,.7)");
}

function renderNNDeepDive() {
  renderAnnotatorDeepDive("nn", "NN", "rgba(231,76,60,.7)");
}

function renderHMDeepDive() {
  renderAnnotatorDeepDive("hm", "HM", "rgba(155,89,182,.7)");
}

/* ── 9. JW Deep Dive ─────────────────────────────────────── */
function renderJWDeepDive() {
  const jw = FEEDBACK_JW || [];
  const container = document.getElementById("view-jw-deep-dive");
  if (!jw.length) {
    container.querySelector(".stats-row").innerHTML =
      "<p style='grid-column:1/-1;color:var(--text-light)'>JW data not loaded. Ensure <code>data/csv_curator_labels_jw.json</code> exists.</p>";
    return;
  }

  const labeled = jw.filter(i => i.sentiment_label != null);
  const unlabeled = jw.filter(i => i.sentiment_label == null);
  const questionCounts = {};
  const boardCounts = {};
  const agentMentions = {};
  const wordCountBuckets = { "1–10": 0, "11–25": 0, "26–50": 0, "51–100": 0, "100+": 0 };

  const AGENT_NAMES = ["novelty", "scope", "ethics", "methodology_reporting",
    "methodology_validation", "integrity"];

  jw.forEach(item => {
    const q = (item.question || "Unknown").slice(0, 60);
    questionCounts[q] = (questionCounts[q] || 0) + 1;

    let board = item.board_id || "unknown";
    if (board.startsWith("screen_")) board = "Screenshot boards";
    else if (board.startsWith("paper_")) board = board;
    boardCounts[board] = (boardCounts[board] || 0) + 1;

    const text = (item.feedback_text || "").toLowerCase();
    const patterns = {
      novelty: ["novelty agent", "novelty"],
      scope: ["scoping agent", "scope agent", "scope"],
      ethics: ["ethics agent", "ethics"],
      methodology_reporting: ["methodology reporting", "methodology report"],
      methodology_validation: ["methodology validation", "methodology valid"],
      integrity: ["integrity agent", "integrity"],
    };
    AGENT_NAMES.forEach(agent => {
      const pats = patterns[agent] || [agent];
      if (pats.some(p => text.includes(p))) {
        agentMentions[agent] = (agentMentions[agent] || 0) + 1;
      }
    });

    const wc = item.auto_flags?.word_count ?? 0;
    if (wc <= 10) wordCountBuckets["1–10"]++;
    else if (wc <= 25) wordCountBuckets["11–25"]++;
    else if (wc <= 50) wordCountBuckets["26–50"]++;
    else if (wc <= 100) wordCountBuckets["51–100"]++;
    else wordCountBuckets["100+"]++;
  });

  document.getElementById("stat-jw-total").textContent = jw.length;
  document.getElementById("stat-jw-labeled").textContent = labeled.length;
  document.getElementById("stat-jw-unlabeled").textContent = unlabeled.length;
  document.getElementById("stat-jw-questions").textContent =
    Object.keys(questionCounts).length;

  // Sentiment donut (labeled only)
  const sentCounts = { positive: 0, neutral: 0, negative: 0, bug: 0 };
  labeled.forEach(i => { sentCounts[i.sentiment_label] = (sentCounts[i.sentiment_label] || 0) + 1; });
  let sentLabels = Object.keys(sentCounts).filter(s => sentCounts[s] > 0);
  let sentData = sentLabels.map(s => sentCounts[s]);
  let sentColors = sentLabels.map(s => COLORS[s]);
  if (sentLabels.length === 0) {
    sentLabels = ["No labeled items"];
    sentData = [1];
    sentColors = ["#bdc3c7"];
  }
  new Chart(document.getElementById("chart-jw-sentiment"), {
    type: "doughnut",
    data: {
      labels: sentLabels.map(s => s.charAt(0).toUpperCase() + s.slice(1)),
      datasets: [{ data: sentData, backgroundColor: sentColors }]
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } }
    }
  });

  // Questions bar
  const qEntries = Object.entries(questionCounts).sort((a, b) => b[1] - a[1]);
  new Chart(document.getElementById("chart-jw-questions"), {
    type: "bar",
    data: {
      labels: qEntries.map(([q]) => q.length > 45 ? q.slice(0, 42) + "…" : q),
      datasets: [{ label: "Feedback items", data: qEntries.map(([, c]) => c),
        backgroundColor: "rgba(46,204,113,.7)" }]
    },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: "y",
      plugins: { legend: { display: false } },
      scales: { x: { beginAtZero: true } } }
  });

  // Boards - collapse screenshot boards
  const boardEntries = Object.entries(boardCounts).sort((a, b) => b[1] - a[1]);
  new Chart(document.getElementById("chart-jw-boards"), {
    type: "bar",
    data: {
      labels: boardEntries.map(([b]) => b),
      datasets: [{ label: "Items", data: boardEntries.map(([, c]) => c),
        backgroundColor: boardEntries.map((_, i) => COLORS.agents[i % COLORS.agents.length]) }]
    },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: "y",
      plugins: { legend: { display: false } },
      scales: { x: { beginAtZero: true } } }
  });

  // Agent mentions
  let agentEntries = Object.entries(agentMentions)
    .sort((a, b) => b[1] - a[1])
    .map(([a, c]) => ({ agent: a, count: c }));
  const agentChartLabels = agentEntries.length
    ? agentEntries.map(e => AGENT_LABELS[e.agent] || e.agent)
    : ["No agent mentions in text"];
  const agentChartData = agentEntries.length
    ? agentEntries.map(e => e.count)
    : [0];
  new Chart(document.getElementById("chart-jw-agent-mentions"), {
    type: "bar",
    data: {
      labels: agentChartLabels,
      datasets: [{ label: "Mentions in text", data: agentChartData,
        backgroundColor: "rgba(155,89,182,.7)" }]
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true } } }
  });

  // Word count buckets
  new Chart(document.getElementById("chart-jw-wordcount"), {
    type: "bar",
    data: {
      labels: Object.keys(wordCountBuckets),
      datasets: [{ label: "Items", data: Object.values(wordCountBuckets),
        backgroundColor: "rgba(52,152,219,.7)" }]
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true } } }
  });

  // Sample feedback
  const samples = jw
    .filter(i => (i.feedback_text || "").trim().length > 20)
    .slice(0, 25);
  const samplesEl = document.getElementById("jw-feedback-samples");
  samplesEl.innerHTML = "<h3>Sample JW Feedback (first 25 with substantial text)</h3>" +
    samples.map(item => {
      const sentTag = item.sentiment_label
        ? `<span class="tag ${item.sentiment_label}">${item.sentiment_label}</span>`
        : "<span class=\"tag\" style=\"background:#ecf0f1;color:#7f8c8d\">unlabeled</span>";
      return `<div class="feedback-item">
        <div class="meta">${item.item_id} &middot; ${item.board_id || "—"} &middot; ${sentTag}</div>
        <div class="text">${escHtml(item.feedback_text || "")}</div>
      </div>`;
    }).join("");
}

/* ── Helpers ──────────────────────────────────────────────── */
function escHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

/* ── Boot ─────────────────────────────────────────────────── */
loadData();
