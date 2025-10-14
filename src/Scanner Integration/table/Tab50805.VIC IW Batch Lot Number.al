table 50805 "VIC IW Batch Lot Number"
{
    DataClassification = ToBeClassified;
    Caption = 'VIC IW Batch Lot Number';

    fields
    {
        // field(1; "Line No."; Integer)
        // {
        //     AutoIncrement = true;
        //     Caption = 'Line No.';
        //     DataClassification = CustomerContent;
        //     Editable = false;
        //     Description = 'Contains the line number of the transaction line..';
        // }
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
        field(20; SequenceNumber; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sequence Number';
        }
        field(30; LotNumber; Code[50])
        {
            Caption = 'Lot No.';
        } 
    }

    keys
    {
        key(Key1; User, FacilityId, BatchNumber, LineIdNumber, SequenceNumber)
        {
        }

        // key(Key2; User, FacilityId, BatchNumber, LineIdNumber)
        // {
        //     Clustered = false;
        //     Unique = false;
        // }
    }
}
