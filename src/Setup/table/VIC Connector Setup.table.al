table 50800 "VIC Connector Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Vicinity Connector Setup';

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(20; "Vicinity Enabled"; Boolean)
        {
            Caption = 'Vicinity Enabled';
            DataClassification = ToBeClassified;
        }
        field(30; "Warehousing Enabled"; Boolean)
        {
            Caption = 'Warehousing Enabled';
            DataClassification = ToBeClassified;
        }
        field(40; "Item Journal Batch"; Code[10])
        {
            Caption = 'Item Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name" = CONST ('ITEM'));
        }
        field(50; "Warehouse Journal Batch"; Code[10])
        {
            Caption = 'Warehouse Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Warehouse Journal Batch".Name WHERE ("Journal Template Name" = CONST ('ADJMT'));
        }
        field(60; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group".Code;
        }
        field(70; "Gen. Journal Batch"; Code[10])
        {
            Caption = 'Gen. Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = CONST ('GENERAL'));
        }
        field(80; ApiUrl; Text[200])
        {
            Caption = 'Vicinity API URL';
            DataClassification = ToBeClassified;
        }
        field(90; CompanyId; Text[10])
        {
            Caption = 'Vicinity Company ID';
            DataClassification = ToBeClassified;
        }
        field(100; ApiUserName; Text[100])
        {
            Caption = 'Vicinity API User Name';
            DataClassification = ToBeClassified;
        }
        field(110; ApiAccessKey; Text[100])
        {
            Caption = 'Vicinity API Access Key';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Get();
        RecordHasBeenRead := true;
    end;
}