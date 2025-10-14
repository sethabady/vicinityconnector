page 50802 "VIC IW Batch Transactions"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'VIC IW Batch Transactions';
    PageType = List;
    SourceTable = "VIC IW Batch Transaction";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Line No.";Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("User";Rec."User")
                {
                    ApplicationArea = All;
                }
                field("Facility ID";Rec.FacilityId)
                {
                    ApplicationArea = All;
                }
                field("Batch Number";Rec.BatchNumber)
                {
                    ApplicationArea = All;
                }
                field(LineIdNumber;Rec.LineIdNumber)
                {
                    ApplicationArea = All;
                }
                field(ComponentId;Rec.ComponentId)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure";Rec.UnitOfMeasure)
                {
                    ApplicationArea = All;
                }
                field("Lot No.";Rec.LotNumber)
                {
                    ApplicationArea = All;
                }
                field("Lot Expiration Date";Rec.LotExpirationDate)
                {
                    ApplicationArea = All;
                }
                field("Lot Receipt Date";Rec.LotReceiptDate)
                {
                    ApplicationArea = All;
                }
                field("Lot Manufacture Date";Rec.LotManufactureDate)
                {
                    ApplicationArea = All;
                }
                field("Quantity";Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity Posted";Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Location Code";Rec.LocationCode)
                {
                    ApplicationArea = All;
                }
                field("Bin Code";Rec.BinCode)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}