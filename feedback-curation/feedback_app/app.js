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

Chart.defaults.font.family = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif";
Chart.defaults.font.size = 12;
Chart.defaults.plugins.legend.labels.usePointStyle = true;
Chart.defaults.plugins.legend.labels.pointStyleWidth = 10;

/* ── Navigation ───────────────────────────────────────────── */
document.querySelectorAll(".nav-link").forEach(link => {
  link.addEventListener("click", e => {
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

  // IM vs NN comparison
  const sentiments = ["positive","neutral","negative","bug"];
  new Chart(document.getElementById("chart-annotator-compare"), {
    type: "bar",
    data: {
      labels: sentiments.map(s => s.charAt(0).toUpperCase() + s.slice(1)),
      datasets: [
        { label: "IM", data: sentiments.map(s => ia.im_distribution[s]||0),
          backgroundColor: "rgba(52,152,219,.7)" },
        { label: "NN", data: sentiments.map(s => ia.nn_distribution[s]||0),
          backgroundColor: "rgba(231,76,60,.7)" },
      ]
    },
    options: { responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
      scales: { y: { beginAtZero: true } } }
  });

  // Disagreement chart
  const disagree = ia.disagreements;
  const dLabels = Object.keys(disagree).sort((a,b) => disagree[b] - disagree[a]);
  new Chart(document.getElementById("chart-disagreements"), {
    type: "bar",
    data: {
      labels: dLabels,
      datasets: [{
        label: "Disagreements",
        data: dLabels.map(k => disagree[k]),
        backgroundColor: "rgba(155,89,182,.7)",
      }]
    },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: "y",
      plugins: { legend: { display: false } },
      scales: { x: { beginAtZero: true } } }
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

  // Feedback samples
  renderNegativeSamples();
}

function renderNegativeSamples() {
  const container = document.getElementById("neg-feedback-samples");
  const nnIndex = {};
  FEEDBACK_NN.forEach(item => { nnIndex[item.item_id] = item; });

  // Build consensus
  const SEVERITY = {bug:0, negative:1, neutral:2, positive:3};
  const negItems = FEEDBACK_IM.filter(item => {
    const nn = nnIndex[item.item_id];
    const imS = item.sentiment_label;
    const nnS = nn ? nn.sentiment_label : imS;
    const cons = imS === nnS ? imS :
      (SEVERITY[imS] < SEVERITY[nnS] ? imS : nnS);
    return cons === "negative";
  }).slice(0, 15);

  container.innerHTML = "<h3>Sample Negative Feedback (first 15)</h3>" +
    negItems.map(item => {
      const nn = nnIndex[item.item_id];
      const agents = (nn && nn.related_agents_label && nn.related_agents_label.length)
        ? nn.related_agents_label : (item.related_agents_label || []);
      const agentStr = agents.length
        ? agents.map(a => AGENT_LABELS[a]||a).join(", ")
        : "General";
      return `<div class="feedback-item">
        <div class="meta">${item.item_id} &middot; Agents: ${agentStr} &middot; IM: <span class="tag ${item.sentiment_label}">${item.sentiment_label}</span> NN: <span class="tag ${nn?nn.sentiment_label:''}">${nn?nn.sentiment_label:''}</span></div>
        <div class="text">${escHtml(item.feedback_text || "")}</div>
      </div>`;
    }).join("");
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

/* ── Helpers ──────────────────────────────────────────────── */
function escHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

/* ── Boot ─────────────────────────────────────────────────── */
loadData();
