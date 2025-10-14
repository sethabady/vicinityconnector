table 50804 "VIC IW Batch Transaction"
{
    DataClassification = ToBeClassified;
    Caption = 'VIC IW Batch Transaction';

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
        field(2; "User"; Code[50])
        {
            Caption = 'User';
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
        field(19; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(20; ConsumptionTransaction; Boolean)
        {
            Caption = 'Consumption Transaction';
        }
        field(21; "Item Tracking"; Enum "Item Tracking Entry Type")
        {
            Caption = 'Item Tracking';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Line No.")
        {
        }
        key(Key2; User, FacilityId, BatchNumber, LineIdNumber)
        {
            Clustered = false;
            Unique = false;
        }
    }
}
