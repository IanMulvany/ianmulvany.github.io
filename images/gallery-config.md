# Gallery Configuration

Define galleries with their profile images, titles, locations, and years.

## Format
```
directory: profile_image: title: location: year
```

## Configuration

```
2025-ff-cologne: DSCF1080.jpeg: Cologne: Germany: 2025
2023-ff-heidelberg: DSCF8200.jpeg: Heidelberg: Germany: 2023
2019-ff-cochem: IMG_2612.jpeg: Cochem: Germany: 2019
2013-ff-bad-camberg: DSCF3645.jpeg: Bad Camberg: Germany: 2013
```



## Notes
- `directory`: The subdirectory name containing the gallery images
- `profile_image`: The filename of the image to use as thumbnail (without path)
- `title`: Display title for the gallery
- `location`: Location name (e.g., "Germany")
- `year`: Year of the gallery
- If year is omitted, it will be extracted from the directory name (e.g., 2025-ff-cologne → 2025)
