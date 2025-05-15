page 50810 "VIC Batch List NoInit"
{
    Caption = 'Vicinity Batches To Scan w/o Init';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "VIC Batch To Scan";
    // CardPageId = "VIC Batch Output";
    SourceTableView = sorting(BatchNumber, FacilityId) order(ascending);
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Batch Number"; Rec.BatchNumber)
                {
                    ApplicationArea = All;
                }
                field("Facility ID"; Rec.FacilityId)
                {
                    ApplicationArea = All;
                }
                field("Formula ID"; Rec.FormulaId)
                {
                    ApplicationArea = All;
                }
                field("Batch Descripton"; Rec.BatchDescription)
                {
                    ApplicationArea = All;
                }
                field("Processing Stage"; Rec.ProcessingStage)
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Plan Start Date"; Rec.PlanStartDate)
                {
                    ApplicationArea = All;
                }
                field("Plan End Date"; Rec.PlanEndDate)
                {
                    ApplicationArea = All;
                }
                field("Actual Start Date"; Rec.ActualStartDate)
                {
                    ApplicationArea = All;
                }
                field("Actual End Date"; Rec.ActualEndDate)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}