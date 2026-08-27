import os
import pypdf

pdfs = [
    "/Users/jaebinchoi/Desktop/iOS_Final_Boss_Masterclass.pdf",
    "/Users/jaebinchoi/Desktop/iOS_Concurrency_Mastery.pdf",
    "/Users/jaebinchoi/Desktop/Tuist_SPM_Mastery.pdf"
]

for pdf_path in pdfs:
    print(f"\n--- Extracting {os.path.basename(pdf_path)} ---")
    try:
        reader = pypdf.PdfReader(pdf_path)
        text = ""
        for page in reader.pages:
            text += page.extract_text() + "\n"
        print(text[:1000]) # Print first 1000 chars to get the gist
    except Exception as e:
        print(f"Error: {e}")
