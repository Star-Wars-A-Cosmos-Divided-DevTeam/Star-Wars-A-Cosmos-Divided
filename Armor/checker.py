import os

# Define the base files and their corresponding normals files
base_files = [f"roof_{i}.png" for i in range(4)] + \
             [f"roof_{i}_33.png" for i in range(4)] + \
             [f"roof_{i}_66.png" for i in range(4)] + \
             [f"roof_{i}_50.png" for i in range(4)]

normals_files = [f"roof_{i}_normals.png" for i in range(4)] + \
                [f"roof_{i}_normals_33.png" for i in range(4)] + \
                [f"roof_{i}_normals_66.png" for i in range(4)] + \
                [f"roof_{i}_normals_50.png" for i in range(4)]

# Function to check if corresponding normals file exists
def check_normals(root, base_file, files):
    # Construct the name of the normals file from the base file
    if "_33" in base_file:
        normals_file = base_file.replace('_33.png', '_normals_33.png')
    elif "_66" in base_file:
        normals_file = base_file.replace('_66.png', '_normals_66.png')
    elif "_50" in base_file:
        normals_file = base_file.replace('_50.png', '_normals_50.png')
    else:
        normals_file = base_file.replace('.png', '_normals.png')
    
    # Check if normals file is in the list of files in the directory
    if normals_file not in files:
        print(f"Missing normals file: {normals_file} for base file: {base_file} in folder: {root}")

# Walk through the directory structure
for root, dirs, files in os.walk('Doonium'):
    print(f"Checking directory: {root}")

    # Check for any roof files in the directory
    roof_files_found = any(file.startswith('roof_') for file in files)

    if roof_files_found:
        # Check each base file to see if the corresponding normals file exists
        for base_file in base_files:
            if base_file in files:
                check_normals(root, base_file, files)
    else:
        print(f"No roof files found in directory: {root}")

