# xml_patent_parser.py - Parse USPTO XML patent files
import xml.etree.ElementTree as ET
import csv
import re
from datetime import datetime
import os

class USPTOXMLParser:
    def __init__(self, xml_file_path, output_csv_path="data/raw/patent_applications.csv"):
        self.xml_file_path = xml_file_path
        self.output_csv_path = output_csv_path
        
        os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)
        
        # --- KEYWORDS REFINED ---
        # This list has been narrowed to core, high-confidence terms.
        self.ai_keywords = [
            'machine learning', 'artificial intelligence', 'neural network', 'deep learning',
            'computer vision', 'decision tree', 'random forest', 'support vector', 'bayesian'
        ]
        
        # 1. Hard exclusions for unrelated fields
        self.exclusion_cpc_prefixes = ['A', 'C']
        
        # 2. High-confidence AI CPCs (no keyword needed)
        self.ai_cpc_core = ['G06N']
        
        # 3. AI-adjacent CPCs (MUST be combined with a keyword)
        self.ai_cpc_adjacent_prefixes = [
            'G06K', 'G06T', 'G06V', 'G05B', 'G05D', 
            'G10L', 'B60R', 'G06F', 'H04L'
        ]

        # --- NEW RULE: Hard-coded Control CPCs ---
        # 4. CPCs to be forced into the 'Control' group, overriding other rules.
        self.hard_coded_control_cpc = ['G06F8', 'G06F40']
        
        # 5. Control group: Non-AI software CPCs
        software_cpc_raw = [
            'G06F9/', 'G06F11/', 'G06F12/', 'G06F15/', 'G06F16/', 
            'G06F17/', 'G06F19/', 'G06F21/', 'G06Q10/', 'G06Q20/', 
            'G06Q30/', 'G06Q40/', 'G06Q50/', 'H04L9/', 'H04L12/', 
            'H04L29/', 'H04N21/', 'H04W4/', 'G06F7/', 'H04L63/',
            'H04L67/', 'G06F38/'
        ]
        self.software_cpc_codes = [c.replace(" ", "").upper() for c in software_cpc_raw]

    def classify_patent(self, title, abstract, cpc_classifications):
        """Classify patent with the latest refined ruleset."""
        
        if not abstract or abstract.strip() == '':
            return 'Ignore'

        text_content = f"{title} {abstract}".lower()
        cpc_text = cpc_classifications.replace(" ", "").upper()
        patent_cpc_list = [c.strip() for c in cpc_text.split(',') if c]

        # --- NEW LOGIC: Multi-step Classification with Overrides ---

        # 1. Hard-coded Control: Check for CPCs that must be 'Control'. This rule runs first.
        if any(cpc.startswith(tuple(self.hard_coded_control_cpc)) for cpc in patent_cpc_list):
            return 'Control'

        # 2. Hard Exclusions: Ignore patents in excluded classes.
        if any(cpc.startswith(tuple(self.exclusion_cpc_prefixes)) for cpc in patent_cpc_list):
            return 'Ignore'

        # 3. High-Confidence AI: Check for core AI CPCs.
        if any(cpc.startswith(tuple(self.ai_cpc_core)) for cpc in patent_cpc_list):
            return 'AI'

        # 4. Keyword-Confirmed AI: Check for adjacent CPCs AND an AI keyword.
        has_adjacent_cpc = any(cpc.startswith(tuple(self.ai_cpc_adjacent_prefixes)) for cpc in patent_cpc_list)
        if has_adjacent_cpc:
            if any(keyword in text_content for keyword in self.ai_keywords):
                return 'AI'

        # 5. General Control Group: Check for other non-AI software CPCs.
        if any(cpc.startswith(tuple(self.software_cpc_codes)) for cpc in patent_cpc_list):
            return 'Control'
                
        return 'Ignore'
        
    def extract_patent_data(self, patent_element):
        """Extract relevant data from a single patent element, now including assignee."""
        data = {
            'applicationNumber': '',
            'assignee': '', # Field for assignee
            'filingDate': '',
            'inventionTitle': '',
            'abstractText': '',
            'cpcClassifications': '',
            'treatmentGroup': 'Ignore'
        }
        try:
            app_ref = patent_element.find('.//application-reference')
            if app_ref is not None:
                doc_number = app_ref.find('.//doc-number')
                if doc_number is not None:
                    data['applicationNumber'] = doc_number.text or ''
                date_elem = app_ref.find('.//date')
                if date_elem is not None:
                    raw_date = date_elem.text or ''
                    if len(raw_date) == 8:
                        data['filingDate'] = f"{raw_date[:4]}-{raw_date[4:6]}-{raw_date[6:8]}"
                    else:
                        data['filingDate'] = raw_date
            
            # --- NEW: Extract Assignee ---
            assignee_elem = patent_element.find('.//assignees/assignee/addressbook/orgname')
            if assignee_elem is not None and assignee_elem.text:
                data['assignee'] = assignee_elem.text.strip()

            title_elem = patent_element.find('.//invention-title')
            if title_elem is not None:
                data['inventionTitle'] = title_elem.text or ''

            abstract_elem = patent_element.find('.//abstract')
            if abstract_elem is not None:
                abstract_parts = [part.strip() for part in abstract_elem.itertext() if part.strip()]
                data['abstractText'] = ' '.join(abstract_parts)

            cpc_classes = []
            for cpc in patent_element.findall('.//classification-cpc-text'):
                if cpc.text:
                    cpc_classes.append(cpc.text.strip())
            data['cpcClassifications'] = ', '.join(cpc_classes)

            data['treatmentGroup'] = self.classify_patent(
                data['inventionTitle'], 
                data['abstractText'], 
                data['cpcClassifications']
            )
        except Exception as e:
            print(f"Error extracting patent data: {e}")
        return data
        
    def parse_file(self):
        """Parse the XML file and extract patent data"""
        print(f"Parsing XML file: {self.xml_file_path}")
        print("This may take a few minutes for large files...")
        try:
            with open(self.xml_file_path, 'r', encoding='utf-8') as f:
                xml_content = f.read()
                xml_content = re.sub(r'<\?xml.*\?>', '', xml_content)
                xml_content = re.sub(r'<!DOCTYPE.*>', '', xml_content)
            wrapped_xml = f"<root>{xml_content.strip()}</root>"
            root = ET.fromstring(wrapped_xml)
        except ET.ParseError as e:
            print(f"\nFATAL XML Parse Error: {e}")
            print("The XML file could not be parsed even after attempting to fix it.")
            return 0, 0
        
        patents_written = 0
        ai_patents = 0
        control_patents = 0
        with open(self.output_csv_path, 'w', newline='', encoding='utf-8') as csvfile:
            # --- CSV Header Updated ---
            fieldnames = ['applicationNumber', 'assignee', 'filingDate', 'inventionTitle', 
                         'abstractText', 'cpcClassifications', 'treatmentGroup']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            for patent_element in root.findall('us-patent-grant'):
                patent_data = self.extract_patent_data(patent_element)
                if patent_data['treatmentGroup'] in ['AI', 'Control']:
                    writer.writerow(patent_data)
                    patents_written += 1
                    if patent_data['treatmentGroup'] == 'AI':
                        ai_patents += 1
                    else:
                        control_patents += 1
                    if patents_written > 0 and patents_written % 1000 == 0:
                        print(f"Written {patents_written:,} relevant patents to CSV...")

        print(f"\nParsing complete!")
        if patents_written > 0:
            print(f"Total relevant patents written to CSV: {patents_written:,}")
            print(f"  - AI-related patents (treatment): {ai_patents:,} ({ai_patents/patents_written*100:.1f}%)")
            print(f"  - Non-AI software patents (control): {control_patents:,} ({control_patents/patents_written*100:.1f}%)")
        else:
            print("No patents classified as 'AI' or 'Control' were found to write to the CSV.")
        print(f"Data saved to: {self.output_csv_path}")
        return patents_written, ai_patents

def main():
    # Configuration
    xml_file = "ipg250819.xml"  # Your USPTO XML file
    output_file = "data/raw/patent_applications.csv"
    
    if not os.path.exists(xml_file):
        print(f"Error: XML file '{xml_file}' not found!")
        print("Please make sure the USPTO XML file is in the current directory.")
        return
        
    # Create parser and process file
    parser = USPTOXMLParser(xml_file, output_file)
    total_patents, ai_patents = parser.parse_file()
    
    print(f"\nYour data is ready for econometric analysis!")
    print(f"The CSV file contains {total_patents:,} patents with treatment group indicators.")

if __name__ == "__main__":
    main()
