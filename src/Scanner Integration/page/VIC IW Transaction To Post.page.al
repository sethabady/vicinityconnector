page 50818 "VIC IW Transaction To Post"
{
    Caption = 'Vicinity IW Batch Transactions';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "VIC IW Batch Transaction";
    InsertAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("User"; Rec."User")
                {
                    ApplicationArea = All;
                    Caption = 'User';
                    Editable = false;
                }
                field("Line No.";Rec."Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'Line No.';
                    Editable = false;
                }
                field("Facility ID"; Rec.FacilityId)
                {
                    ApplicationArea = All;
                    Caption = 'Facility ID';
                    Editable = false;
                }
                field("Batch Number"; Rec.BatchNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Batch Number';
                    Editable = false;
                }
                field("Line ID Number"; Rec.LineIdNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Line ID Number';
                    Editable = false;            
                }
                field("Component ID"; Rec.ComponentId)
                {
                    ApplicationArea = All;
                    Caption = 'Component ID';
                    Editable = false;
                }
                field("Lot No."; Rec.LotNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Lot No.';
                    Editable = false;
                }
                field("Quantity"; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    Editable = false;
                }
                field("Consumption Transaction"; Rec.ConsumptionTransaction)
                {
                    ApplicationArea = All;
                    Caption = 'Consumption Transaction';
                    Editable = false;
                }
            }
        }
    }
}
