table 50805 "VIC IW Consumable Lots"
{
    DataClassification = ToBeClassified;
    Caption = 'VIC IW Lots That Can Be Consumed';    

    fields
    {
        field(10; ComponentId; code[32])
        {
            DataClassification = ToBeClassified;
            Caption = 'Component ID';
        }
        field(20; LocationCode; Code[10])
        {
            Caption = 'Location Code';
        }
        field(30; LotNumber; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(35; ReceiptDate; Date)
        {
            Caption = 'Lot Receipt Date';
        }
        field(36; ExpirationDate; Date)
        {
            Caption = 'Lot Expiration Date';
        }
        field(37; ManufactureDate; Date)
        {
            Caption = 'Lot Manufacture Date';
        }
        field(40; BinCode; Code[20])
        {
            Caption = 'Bin Code';
        }
        field(50; QtyOnHand; Decimal)
        {
            Caption = 'Quantity On Hand';
        }
        field(60; QtyAllocated; Decimal)
        {
            Caption = 'Quantity Allocated';
        }
    }
}
