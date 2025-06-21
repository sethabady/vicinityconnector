table 50806 "VIC IW Batch"
{
    DataClassification = ToBeClassified;
    Caption = 'Batch to Scan';
    
    fields
    {
        field(10; FacilityId; Code[15])
        {
            Caption = 'Facility ID';
        }
        field(20; BatchNumber; Code[20])
        {
            Caption = 'Batch Number';
        }
        field(30; FormulaId; Code[32])
        {
            Caption = 'Formula ID';
        }
        field(40; BatchDescription; Text[60])
        {
            Caption = 'Batch Description';
        }
        field(50; PlanStartDate; Date)
        {
            Caption = 'Plan Start Date';
        }
        field(60; ProcessingStage; Enum "VIC Batch Processing Stage")
        {
            Caption = 'Processing Stage';
        }
        field(70; Status; Enum "VIC Batch Status")
        {
            Caption = 'Status';
        }
        field(80; PlanEndDate; Date)
        {
            Caption = 'Plan End Date';
        }
        field(90; ActualStartDate; Date)
        {
            Caption = 'Actual Start Date';
        }
        field(100; ActualEndDate; Date)
        {
            Caption = 'Actual End Date';
        }
        field(110; Barcode; Text[250])
        {
            Caption = 'Barcode';
        }
        field(120; PostThruToBC; Boolean)
        {
            Caption = 'Post Thru to BC';
        }
        field(130; User; Code[50])
        {
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
