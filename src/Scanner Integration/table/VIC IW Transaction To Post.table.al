table 50804 "VIC IW Transaction To Post"
{
    DataClassification = ToBeClassified;
    Caption = 'VIC IW Transaction To Post';    

    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            Editable = false;
            Description = 'Contains the line number of the transaction line..';
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            Description = 'Contains the ID of the user that created the transaction line.';
        }
        field(3; FacilityId; Code[15])
        {
            DataClassification = ToBeClassified;
            Caption = 'Facility ID';
        }
        field(4; BatchNumber; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Batch Number';
        }
        field(10; LineIdNumber; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Line ID Number';
        }
        field(11; ComponentId; code[32])
        {
            DataClassification = ToBeClassified;
            Caption = 'Component ID';
        }
        field(12; UnitOfMeasure; Text[50])
        {
            Caption = 'Unit of Measure';
        }
        field(13; LotNumber; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(14; LotExpirationDate; Date)
        {
            Caption = 'Lot Expiration Date';
        }
        field(15; LotReceiptDate; Date)
        {
            Caption = 'Lot Receipt Date';
        }
        field(16; LotManufactureDate; Date)
        {
            Caption = 'Lot Manufacture Date';
        }
        field(17; LocationCode; Code[10])
        {
            Caption = 'Location Code';
        }
        field(18; BinCode; Code[20])
        {
            Caption = 'Bin Code';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }
}
