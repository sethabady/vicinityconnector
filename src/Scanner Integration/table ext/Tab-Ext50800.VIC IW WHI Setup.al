tableextension 50800 "VIC IW WHI Setup" extends "WHI Setup"
{
    fields
    {
        field(50800; PostToBC; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'VIC IW Facility ID';
            Description = 'Specifies the Facility ID to be used for VIC IW transactions.';
            InitValue = true;
        }
    }
}

