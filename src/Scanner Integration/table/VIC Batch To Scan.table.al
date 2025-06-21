table 50801 "VIC Batch To Scan"
{
    DataClassification = ToBeClassified;
    Caption = 'Batch to Scan';
    
    fields
    {
        field(1; FacilityId; Code[15])
        {
            DataClassification = ToBeClassified;
            Caption = 'Facility ID';
        }
        field(2; BatchNumber; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Batch Number';
        }
        field(3; FormulaId; Code[32])
        {
            DataClassification = ToBeClassified;
            Caption = 'Formula ID';
        }
        field(4; BatchDescription; Text[60])
        {
            DataClassification = ToBeClassified;
            Caption = 'Batch Description';
        }
        field(5; PlanStartDate; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Plan Start Date';
        }
        field(6; ProcessingStage; Enum "VIC Batch Processing Stage")
        {
            DataClassification = ToBeClassified;
            Caption = 'Processing Stage';
        }
        field(7; Status; Enum "VIC Batch Status")
        {
            DataClassification = ToBeClassified;
            Caption = 'Status';
        }
        field(8; PlanEndDate; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Plan End Date';
        }
        field(9; ActualStartDate; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Actual Start Date';
        }
        field(10; ActualEndDate; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Actual End Date';
        }
        field(11; Barcode; Text[250])
        {
            Caption = 'Barcode';
            DataClassification = ToBeClassified;
        }
        field(200; PostThruToBC; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Post Thru to BC';
        }
        field(210; User; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'User ID';
        }
    }

    keys
    {
        key(Key1; FacilityId, BatchNumber)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;
}
