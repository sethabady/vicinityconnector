page 50801 "VIC IW Batch Outputs"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'VIC IW Batch Outputs';
    PageType = List;
    SourceTable = "VIC IW Batch Output";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
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
                field("User"; Rec."User")
                {
                    ApplicationArea = All;
                }
                field(ComponentId; Rec.ComponentId)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(LotNumber;Rec.LotNumber)
                {
                    ApplicationArea = All;
                }
                field(QuantityOrdered; Rec.QuantityOrdered)
                {
                    ApplicationArea = All;
                }
                field(QuantityCompleted; Rec.QuantityCompleted)
                {
                    ApplicationArea = All;
                }
                field(QuantityRemaining; Rec.QuantityRemaining)
                {
                    ApplicationArea = All;
                }
                field(QuantityUnposted; Rec.QuantityUnposted)
                {
                    ApplicationArea = All;
                }
                field(QuantityToComplete; Rec.QuantityToComplete)
                {
                    ApplicationArea = All;
                }
                field(UnitOfMeasure; Rec.UnitOfMeasure)
                {
                    ApplicationArea = All;
                }
            }
        }   
    }
}
