pageextension 50800 "VIC IW WHI Setup" extends "WHI Setup"
{
    layout
    {
        addafter(General)
        {
            group(Vicinity)
            {
                Caption = 'Vicinity';
                field(PostToBC; Rec.PostToBC)
                {
                    ApplicationArea = All;
                    Caption = 'Post To BC';
                    ToolTip = 'Specifies whether to post transactions to Business Central.';
                }
            }
        }
    }
}
