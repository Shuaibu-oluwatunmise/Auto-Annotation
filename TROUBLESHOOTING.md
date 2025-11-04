# Troubleshooting Guide

Last Updated: November 4, 2025

## Common Issues

### 1. OpenCV Path Object Error

**Error Message:**
```
TypeError: Can't convert object to 'str' for 'filename'
cv2.error: OpenCV(4.8.1) :-1: error: (-5:Bad argument) in function 'imread'
```

**Cause:**
`autodistill-grounding-dino==0.1.2` doesn't properly handle `pathlib.Path` objects when passing them to OpenCV's `cv2.imread()`. This affects Python 3.12.9 with opencv-python 4.8.1.78.

**Solution Option 1: Use Our Fixed File (Easiest)**

1. After installing requirements, locate your package:
   - **Windows (system Python):** 
```
     C:\Users\<YourUsername>\AppData\Local\Programs\Python\Python312\Lib\site-packages\autodistill_grounding_dino\
```
   - **Windows (venv):**
```
     .\venv\Lib\site-packages\autodistill_grounding_dino\
```
   - **Linux/Mac:**
```
     /usr/local/lib/python3.12/site-packages/autodistill_grounding_dino/
     # or in venv: ./venv/lib/python3.12/site-packages/autodistill_grounding_dino/
```

2. **Backup the original file:**
```bash
   cp grounding_dino_model.py grounding_dino_model.py.backup
```

3. **Copy our fixed version:**
```bash
   # From the repo root
   cp fixes/grounding_dino_model.py <package-location>/grounding_dino_model.py
```

**Solution Option 2: Manual Fix**

If you prefer to apply the fix manually:

1. Open `grounding_dino_model.py` in the package location
2. Add `numpy` import at the top (around line 8):
```python
   import numpy as np
```

3. Find the `predict` method (around line 35) and replace:
```python
   # OLD CODE
   def predict(self, input: str) -> sv.Detections:
       image = cv2.imread(input)
```
   
   With:
```python
   # NEW CODE
   def predict(self, input: str) -> sv.Detections:
       if isinstance(input, (str, bytes, os.PathLike)):
           image = cv2.imread(str(input))
       elif isinstance(input, np.ndarray):
           image = input
       else:
           raise TypeError(f"Unexpected input type for cv2.imread: {type(input)}")
```

4. Save and run your script

**Solution Option 3: Downgrade Package**
```bash
pip uninstall autodistill-grounding-dino
pip install autodistill-grounding-dino==0.1.1
```

**Why This Happens:**

Newer versions of OpenCV (4.8+) are stricter about type checking and don't automatically convert `pathlib.Path` objects to strings. The `autodistill-grounding-dino` package passes Path objects directly without conversion.

---

### 2. CUDA Not Available / GPU Not Detected

**Error Message:**
```
WARNING: CUDA not available. GroundingDINO will run very slowly.
NVIDIA GeForce RTX 5080 with CUDA capability sm_120 is not compatible
```

**Cause:**
Your GPU is too new for the installed PyTorch version, or CUDA drivers aren't installed.

**Solution:**

Force CPU mode (annotation will be slower but works):

**Windows PowerShell:**
```powershell
$env:CUDA_VISIBLE_DEVICES="-1"
python Auto_Annotate.py
```

**Linux/Mac:**
```bash
CUDA_VISIBLE_DEVICES=-1 python Auto_Annotate.py
```

**Or add to script permanently:**
Add this at the very top of `Auto_Annotate.py`:
```python
import os
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'
```

---

### 3. NumPy Version Conflicts

**Error Message:**
```
A module that was compiled using NumPy 1.x cannot be run in NumPy 2.x
```

**Solution:**
```bash
pip uninstall numpy
pip install "numpy<2"
```

---

### 4. Empty or Incorrect Annotations

**Problem:** No bounding boxes detected or wrong objects annotated.

**Solutions:**

1. **Improve text prompts:**
```python
   # Bad
   "Mouse": "mouse"
   
   # Better
   "Mouse": "computer mouse"
   
   # Even better
   "Mouse": "black computer mouse on desk"
```

2. **Check image quality:**
   - Images should be clear, not blurry
   - Objects should be reasonably sized (not too small)
   - Good lighting

3. **Adjust thresholds:**
```python
   base_model = GroundingDINO(
       ontology=ontology,
       box_threshold=0.25,  # Lower = more detections (default: 0.35)
       text_threshold=0.20   # Lower = more liberal matching (default: 0.25)
   )
```

---

### 5. Slow Processing on CPU

**Problem:** Annotation takes 2-3 seconds per image.

**Solutions:**

1. **Use Google Colab (free GPU):**
   - Upload your images
   - Run the script there
   - Download annotations

2. **Process in batches:**
   - Annotate 500 images at a time
   - Merge datasets later

3. **Reduce image size:**
   - Resize images to 640px before annotation
   - Grounding DINO works well with smaller images

---

### 6. Missing Label Files

**Error:** Mismatch between number of images and labels.

**Solution:**

Run our cleanup script:
```powershell
# Finds and deletes images without labels
.\find_missing_labels.ps1
```

Or check manually:
```bash
# Count images
ls YOLO_DATA/train/images | measure

# Count labels  
ls YOLO_DATA/train/labels | measure
```

---

## Tested Working Configuration
```
Python: 3.12.9
opencv-python: 4.8.1.78
numpy: 1.26.4 (< 2.0)
autodistill: 0.1.29
autodistill-grounding-dino: 0.1.2 (with our fix)
torch: 2.0.0+
scikit-learn: 1.0.0+
```

---

## Still Having Issues?

1. Check you're using the correct Python version (3.10-3.12)
2. Make sure you're in a virtual environment
3. Try completely fresh install:
```bash
   # Delete venv
   rm -rf venv
   
   # Recreate
   python -m venv venv
   source venv/bin/activate  # or .\venv\Scripts\activate on Windows
   
   # Reinstall
   pip install -r requirements.txt
   
   # Apply fix
   cp fixes/grounding_dino_model.py venv/lib/.../autodistill_grounding_dino/
```

4. Open a GitHub issue with:
   - Your Python version
   - Error message (full stack trace)
   - Operating system

---

**Last Updated:** November 4, 2025  
**Tested On:** Windows 11, Python 3.12.9