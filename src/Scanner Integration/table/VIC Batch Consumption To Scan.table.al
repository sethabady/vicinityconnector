table 50803 "VIC Batch Consumption To Scan"
{
    DataClassification = ToBeClassified;
    Caption = 'Batch Consumption to Scan';    

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
        field(3; LineIdNumber; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Line ID Number';
        }
        field(4; ComponentId; code[32])
        {
            DataClassification = ToBeClassified;
            Caption = 'Component ID';
        }
        field(5; Description; text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(6; QuantityOrdered; Decimal)
        {
            Caption = 'Quantity Ordered';
            DecimalPlaces = 0 : 5;
        }
        field(13; QuantityCompleted; Decimal)
        {
            Caption = 'Quantity Completed';
            DecimalPlaces = 0 : 5;
        }
        field(7; QuantityRemaining; Decimal)
        {
            Caption = 'Quantity Remaining';
            DecimalPlaces = 0 : 5;
        }
        field(14; QuantityUnposted; Decimal)
        {
            Caption = 'Quantity Unposted';
            DecimalPlaces = 0 : 5;
        }
        field(8; QuantityToComplete; Decimal)
        {
            Caption = 'Quantity to Complete';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 999999;
        }
        field(9; UnitOfMeasure; Text[50])
        {
            Caption = 'Unit of Measure';
        }
        field(10; LotNumber; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(11; LocationCode; Code[10])
        {
            Caption = 'Location Code';
        }
        field(12; BinCode; Code[20])
        {
            Caption = 'Bin Code';
        }
        field(15; "ExpirationDate"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(16; ScanType; Enum "VIC Batch Scan Type")
        {
            DataClassification = ToBeClassified;
            Caption = 'Scan Type';
        }
        field(17; ParentComponentId; code[32])
        {
            DataClassification = ToBeClassified;
            Caption = 'Parent Component ID';
        }
    }

    keys
    {
        key(Key1; FacilityId, BatchNumber, LineIdNumber)
        {
            Clustered = true;
        }
    }
}