/**
 * Prompt improvement suggestions per agent.
 * Derived from negative/neutral feedback analysis of 329 curated items.
 * Agents are ordered from most to least in need of improvement.
 */
const PROMPT_SUGGESTIONS = [
  {
    agent: "ethics",
    avg_score: 1.88,
    negative_count: 29,
    positive_count: 6,
    summary: "Lowest-performing agent. Frequently flags irrelevant ethical issues, fails to understand study design nuances, and relies too heavily on generic legal frameworks rather than journal-specific policies.",
    issues: [
      "Checks irrelevant ethical sources (e.g. flagging ethics approval for study types that are clearly exempt, such as systematic review protocols)",
      "Does not understand the nuance of ethical requirements for different study designs (clinical trials vs observational vs qualitative)",
      "Relies too heavily on legal frameworks rather than journal-specific ethics policies",
      "Fails to validate whether claimed ethics exemptions are appropriate for the study design",
      "Produces overwhelming volume of information that is not necessarily relevant to the editorial decision",
      "Misses vague statements about ethics approval (e.g. blanket approvals covering multiple centres)"
    ],
    prompts: [
      {
        text: "Before assessing ethics compliance, first classify the study design precisely:\n- Clinical trial / interventional study → Full ethics approval required\n- Observational study (cohort, case-control, cross-sectional) → Ethics approval typically required but exemptions may apply\n- Systematic review / meta-analysis → Usually exempt from ethics approval\n- Case series / case report → May require consent but not full ethics review\n- Qualitative study → Ethics approval required, check consent procedures\n- Study protocol → Check if prospective ethics approval is mentioned\n\nApply the appropriate ethics requirements based on the classified design. Do NOT flag missing ethics approval for exempt study types.",
        rationale: "Addresses the most frequent complaint: agents flagging ethics issues for study types that don't require ethics approval."
      },
      {
        text: "Focus your ethics assessment on the journal's specific policies rather than generic legal or regulatory frameworks. Prioritise checking for:\n1. Appropriate ethics committee/IRB approval statement for the study type\n2. Informed consent documentation (where applicable)\n3. Data protection and participant privacy compliance\n4. Conflicts of interest declarations\n\nDo NOT produce lengthy legal analysis. Keep the ethics report concise and actionable: flag only genuine gaps or concerns.",
        rationale: "Reduces output volume and irrelevant legal discussion that editors find overwhelming."
      },
      {
        text: "When a study claims ethics exemption or waiver, evaluate whether the exemption is valid for the specific study design and jurisdiction before flagging it as an issue. For multi-centre studies, verify whether the stated approval covers all participating centres. If the approval statement is ambiguous, flag it as 'unclear' rather than 'missing'.",
        rationale: "Addresses feedback about false positives when exemptions are valid but flagged anyway."
      }
    ]
  },
  {
    agent: "scope",
    avg_score: 1.99,
    negative_count: 12,
    positive_count: 6,
    summary: "Second-lowest performer. Frequently misidentifies study types, interprets journal scope information too literally from the website, and fails to handle edge-case submission types like case series.",
    issues: [
      "Wrongly identifies study types (e.g. classifying a case series as being in scope when it should be out of scope)",
      "Takes journal scope information from the website too literally without contextual interpretation",
      "Does not handle study types that are implicitly out of scope (not explicitly listed on the website)",
      "Confuses related but distinct study types (case series vs cohort studies, protocols vs completed studies)",
      "Insufficient depth for editors who need nuanced scope assessment"
    ],
    prompts: [
      {
        text: "When assessing scope, perform a two-step classification:\n\nStep 1 - Classify the submission type precisely:\n  RCT, cohort study, case-control, cross-sectional, case series, case report,\n  systematic review, meta-analysis, protocol, qualitative study, mixed-methods,\n  methodology paper, editorial, letter, commentary\n\nStep 2 - Match against journal scope:\n  Check not only what the journal website explicitly states as in-scope, but also\n  consider implicit exclusions. For example, if a journal focuses on original\n  research and does not mention case reports or case series, treat these as\n  likely out of scope and flag for editor review.\n\nAlways state your classification clearly and explain your reasoning.",
        rationale: "Addresses the most common scope errors: misclassification of study type leading to wrong scope decisions."
      },
      {
        text: "The journal scope description from the website is guidance, not an exhaustive ruleset. Apply editorial judgement:\n- If a study type is not explicitly mentioned as in-scope, it may still be out of scope\n- Consider the journal's typical publication patterns and audience\n- For borderline cases, recommend the submission be flagged for editorial review rather than making a definitive in/out decision\n- For transfer decisions: suggest specific alternative journals that may be a better fit based on the study type and topic",
        rationale: "Directly addresses feedback about the tool being useful for transfer decisions but too literal in scope interpretation."
      }
    ]
  },
  {
    agent: "integrity",
    avg_score: 2.94,
    negative_count: 7,
    positive_count: 13,
    summary: "Mid-tier agent with good positive feedback for publication ethics checks, but could be more targeted in its output. Users value the author publication pattern analysis but want less noise.",
    issues: [
      "Lists all author publications rather than focusing on concerning patterns",
      "Output could be more prioritised by severity of concern",
      "Sometimes produces findings that are not actionable for editors",
      "Could better differentiate between critical integrity concerns and minor observations"
    ],
    prompts: [
      {
        text: "Prioritise integrity findings by severity level:\n\nCRITICAL (flag immediately):\n- Evidence of data fabrication or manipulation indicators\n- Plagiarism or significant text overlap\n- Undisclosed duplicate/overlapping publications\n- Image manipulation concerns\n\nMODERATE (report clearly):\n- Undisclosed conflicts of interest\n- Potential salami slicing (rapid similar publications by same authors)\n- Selective outcome reporting indicators\n- Unusual authorship patterns\n\nMINOR (mention briefly):\n- Formatting issues in declarations\n- Minor inconsistencies in author details\n\nPresent CRITICAL items first. For author publication patterns, only flag concerning patterns (e.g. rapid publication of near-identical studies) rather than listing all publications.",
        rationale: "Users specifically praised the integrity checks but asked for better prioritisation and less noise."
      },
      {
        text: "When analysing author publication history, focus on:\n1. Potential salami slicing: multiple papers with very similar methods/populations published in short timeframes\n2. Self-citation patterns that may inflate impact\n3. Competing publications on the same topic that the authors should have disclosed\n\nDo NOT list all publications by each author. Only highlight specific publications that raise concerns, with a brief explanation of why each is flagged.",
        rationale: "Addresses feedback requesting more targeted analysis of author patterns."
      }
    ]
  },
  {
    agent: "novelty",
    avg_score: 3.18,
    negative_count: 6,
    positive_count: 16,
    summary: "Good performer with strong positive feedback. Praised for identifying competing works and research gaps. Occasional issues with field-specific context and missing nuance in novelty assessment for certain study types.",
    issues: [
      "Sometimes misses field-specific context when assessing novelty",
      "For systematic reviews, does not always check against existing reviews on the same topic effectively",
      "Can produce repetitive output when listing competing works",
      "Occasionally flags novelty concerns that are not relevant to the specific manuscript type"
    ],
    prompts: [
      {
        text: "When assessing novelty, tailor your approach to the study type:\n\n- For systematic reviews/meta-analyses: Search specifically for existing reviews on the same research question. Check PROSPERO for registered protocols. Assess whether the inclusion criteria, population, or analytical approach differ meaningfully from prior reviews.\n- For original research: Identify the specific contribution beyond existing literature. Consider whether the population, setting, methodology, or outcome measures add new knowledge.\n- For study protocols: Assess whether the planned methodology addresses a genuine gap. Check if similar studies are already underway.\n\nAlways frame novelty relative to the specific subfield, not just the broad topic area.",
        rationale: "Addresses feedback about novelty assessment being too generic and not field-specific enough."
      },
      {
        text: "When listing competing or overlapping works, limit to the 5 most relevant publications. For each, briefly state:\n1. How it relates to the current manuscript\n2. What the current manuscript adds beyond it\n\nAvoid repetitive listing. If many similar studies exist, summarise the pattern (e.g. '12 similar cohort studies exist in this population, the most recent being [X]') rather than listing each one.",
        rationale: "Reduces repetitive output that editors found overwhelming, while preserving the valued competing-works analysis."
      }
    ]
  },
  {
    agent: "methodology_validation",
    avg_score: 3.50,
    negative_count: 9,
    positive_count: 12,
    summary: "Strong performer especially praised for statistical and mathematical checks. Users valued that it catches errors they wouldn't manually check. Needs improvement in context sensitivity when assessing severity of methodological flaws.",
    issues: [
      "Not sufficiently sensitive to context when judging how critical a methodological flaw really is",
      "Sometimes flags theoretical concerns that don't materially affect the study conclusions",
      "Does not consider the study's own stated limitations when flagging issues",
      "Could better differentiate between flaws that affect validity vs those that affect reporting quality"
    ],
    prompts: [
      {
        text: "When identifying methodological flaws, assess each one on two dimensions:\n\n1. VALIDITY IMPACT: Does this flaw threaten the validity of the study conclusions?\n   - High impact: Bias likely changes the direction or significance of results\n   - Medium impact: Bias may attenuate or inflate effect sizes but direction is preserved\n   - Low impact: Flaw is present but unlikely to change interpretation\n\n2. REMEDIABILITY: Can this be addressed in revision?\n   - Addressable: Authors can fix in revision (e.g. additional analysis, better reporting)\n   - Not addressable: Fundamental design flaw that cannot be retroactively fixed\n\nPresent high-validity-impact items first. For each flaw, state its practical consequence for interpreting the study results.",
        rationale: "Directly addresses the most common criticism: flagging methodological issues without assessing their actual impact on conclusions."
      },
      {
        text: "Before flagging a methodological concern, check whether the authors have already acknowledged it in their limitations section. If they have:\n- Note that the limitation is acknowledged\n- Assess whether their mitigation strategy (if any) is adequate\n- Only flag as a concern if the acknowledgement is insufficient or the mitigation is inadequate\n\nThis prevents the report from appearing to miss context that the authors themselves have provided.",
        rationale: "Addresses feedback that the agent flags issues already discussed by authors, making the report feel context-unaware."
      }
    ]
  },
  {
    agent: "methodology_reporting",
    avg_score: 3.55,
    negative_count: 22,
    positive_count: 16,
    summary: "Highest helpfulness score but also significant negative feedback volume (22 items). Praised for catching reporting discrepancies but criticised for missing study design nuances, high output volume, and errors that cascade into downstream analysis.",
    issues: [
      "Sometimes misidentifies the study design, causing knock-on errors in reporting checklist application",
      "Produces very high volume of output that is hard to parse quickly",
      "Errors in methodology reporting assessment cause downstream agents to miss key issues",
      "Misses nuances of specific designs (e.g. retrospective cohort vs prospective cohort)",
      "Lacks journal-specific first-decision framing (e.g. BMJ Open specific requirements)"
    ],
    prompts: [
      {
        text: "CRITICAL FIRST STEP: Before applying any reporting checklist, classify the study design with high confidence. State your classification explicitly and the evidence from the manuscript that supports it. If the design is ambiguous, flag the ambiguity rather than guessing.\n\nCommon design classifications and their reporting checklists:\n- RCT → CONSORT\n- Observational cohort → STROBE (cohort)\n- Case-control → STROBE (case-control)\n- Cross-sectional → STROBE (cross-sectional)\n- Systematic review → PRISMA\n- Diagnostic accuracy → STARD\n- Qualitative → COREQ / SRQR\n- Protocol → SPIRIT (trials) or PRISMA-P (reviews)\n\nDo NOT apply the wrong checklist. If uncertain about design, note the uncertainty.",
        rationale: "Addresses the cascading error problem: misclassifying the study design leads to wrong checklist application and missed critical items."
      },
      {
        text: "Limit your reporting assessment to the 10 most critical items from the applicable checklist. For each:\n1. State the checklist item\n2. Whether it is adequately reported, partially reported, or not reported\n3. Where in the manuscript it appears (or should appear)\n\nFor a quick editorial overview, also provide a 3-line summary at the top:\n- Study design: [classification]\n- Key reporting gaps: [top 3 items]\n- Overall reporting quality: [Good / Acceptable / Needs revision / Major gaps]",
        rationale: "Addresses the output volume problem while preserving the detailed checklist users valued. The summary enables quick editorial scanning."
      }
    ]
  }
];
