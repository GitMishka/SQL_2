import os

folder_names = [
    "1MPALL - Morning Pointe of Alabaster",
    "ATHS - Morning Pointe of Athens",
    "BRWD - Morning Pointe of Brentwood",
    "CALH - Morning Pointe of Calhoun",
    "CGLD - Lantern at Morning Pointe of Collegedale",
    "CHLT - Lantern at Morning Pointe of Chattanooga",
    "CHTT - Morning Pointe of Chattanooga",
    "CLIN - Lantern at Morning Pointe of Clinton",
    "COLM - Morning Pointe of Columbia",
    "DANS - Morning Pointe Danville Senior Living",
    "DANY - Morning Pointe of Danville",
    "EHAM - Morning Pointe of East Hamilton",
    "EHML - Lantern at Morning Pointe of East Hamilton",
    "FKTL - Lantern at Morning Pointe Franklin TN",
    "FKTN - Morning Pointe of Franklin TN",
    "FKRL - Lantern at Morning Pointe of Frankfort",
    "FKRT - Morning Pointe of Frankfort",
    "FRLN - Morning Pointe of Franklin",
    "GRNB - Morning Pointe of Greenbriar",
    "GRNV - Morning Pointe of Greeneville",
    "HARD - Morning Pointe of Hardin Valley",
    "HIXN - Morning Pointe of Hixson",
    "HPPY - Morning Pointe of Happy Valley",
    "KNOX - Morning Pointe of Knoxville",
    "KNXL - Lantern at Morning Pointe of Knoxville",
    "LENC - Morning Pointe of Lenoir City",
    "LENL - Lantern at Morning Pointe of Lenoir City",
    "LEXE - Morning Pointe of Lexington East",
    "LEXL - Lantern at Morning Pointe of Lexington",
    "LEXN - Morning Pointe of Lexington",
    "LVLL - Lantern at Morning Pointe Louisville",
    "LVLM - Morning Pointe of Louisville",
    "POWL - Morning Pointe of Powell",
    "PWLL - Lantern at Morning Pointe of Powell",
    "RICH - Morning Pointe of Richmond",
    "RUSL - Lantern at Morning Pointe of Russell",
    "RUSS - Morning Pointe of Russell",
    "SPRH - Morning Pointe of Spring Hill",
    "SPRL - Lantern at Morning Pointe of Spring Hill",
    "TULA - Morning Pointe of Tullahoma",
    "TUSC - Morning Pointe of Tuscaloosa"
]

base_directory = "/path/to/your/desired/directory"

for name in folder_names:
    directory_path = os.path.join(base_directory, name)
    os.makedirs(directory_path, exist_ok=True)  # This will create the directory if it doesn't exist
    print(f"Created: {directory_path}")
