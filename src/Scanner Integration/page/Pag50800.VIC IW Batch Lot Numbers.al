page 50800 "VIC IW Batch Lot Numbers"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'VIC IW Batch Lot Numbers';
    PageType = List;
    SourceTable = "VIC IW Batch Lot Number";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                // field("Line No."; Rec."Line No.")
                // {
                //     ApplicationArea = All;
                // }
                field("User"; Rec."User")
                {
                    ApplicationArea = All;
                }
                field(FacilityId; Rec.FacilityId)
                {
                    ApplicationArea = All;
                }
                field(BatchNumber; Rec.BatchNumber)
                {
                    ApplicationArea = All;
                }
                field(LineIdNumber; Rec.LineIdNumber)
                {
                    ApplicationArea = All;
                }
                field(SequenceNumber; Rec.SequenceNumber)
                {
                    ApplicationArea = All;
                }
                field(LotNumber; Rec.LotNumber)
                {
                    ApplicationArea = All;
                }
            }
        }

    }
}
