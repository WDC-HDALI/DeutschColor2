pageextension 50104 "WDC ChequeListPagExt" extends "Cheque List" //50010
{
    layout
    {
        addafter(Status)
        {

            field("Description Status"; Rec."Description Status")
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {

    }
}