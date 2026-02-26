# Feedback Item Viewer

Standalone viewer to explore feedback items from the annotator JSON files (IM, NN, JW, HM).

## Usage

**Option 1: Load from data folder** (requires a local server)

```bash
# From project root or curator_label_report
python -m http.server 8080
# Open http://localhost:8080/feedback_viewer/  (if from curator_label_report)
# Or http://localhost:8080/curator_label_report/feedback_viewer/  (if from project root)
```

Then click **Load from data folder** to fetch the JSON files from `../data/`.

**Option 2: Load JSON files manually**

Click **Load JSON files…** and select one or more of:
- `csv_curator_labels_im.json`
- `csv_curator_labels_nn.json`
- `csv_curator_labels_jw.json`
- `csv_curator_labels_hm.json`

This works offline and without a server.

## Features

- **Summary stats** per annotator (total items, sentiment breakdown)
- **Filters**: annotator, sentiment, text search
- **Pagination** with configurable items per page
- **Item detail modal**: click any item to see full JSON and key fields
