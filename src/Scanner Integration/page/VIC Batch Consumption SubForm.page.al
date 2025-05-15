page 50807 "VIC Batch Consumption SubForm"
{
    AutoSplitKey = true;
    Caption = 'Consumptions';
    LinksAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "VIC Batch Consumption To Scan";
    //    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = true;
                field("Scan Type"; Rec.ScanType)
                {
                    ApplicationArea = All;
                    Editable = false ;
                }
                field("Parent Component ID"; Rec.ParentComponentId)
                {
                    ApplicationArea = All;
                    Editable = false ;
                }
                field("Component ID"; rec.ComponentId)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Description"; rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; rec.LocationCode)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bin Code"; rec.BinCode)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Ordered"; rec.QuantityOrdered)
                {
                    Caption = 'Qty. Ordered';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Completed"; rec.QuantityCompleted)
                {
                    Caption = 'Qty. Completed';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Remaining"; rec.QuantityRemaining)
                {
                    Caption = 'Qty. Remaining';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Unposted"; rec.QuantityUnposted)
                {
                    Caption = 'Qty. Unposted';
                    ApplicationArea = All;
                }
                field("Qty. to Complete"; rec.QuantityToComplete)
                {
                    Caption = 'Qty. to Complete';
                    ApplicationArea = All;
                }
                field("Unit of Measure"; rec.UnitOfMeasure)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Lot Number"; rec.LotNumber)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // var
    //     BatchEndItemPostPage: Page VICBatchEndItemPost;

    // trigger OnInit()
    // var
    //     VICBatch: Record VICBatch;
    //     VICBatchEndItem: Record VICBatchEndItem;
    // begin
    //     // VICBatch.Get(rec.FacilityId, rec.BatchNumber);
    //     // VICBatchEndItem.Init();
    //     //        VICBatchEndItem.FacilityId = 
    // end;
}