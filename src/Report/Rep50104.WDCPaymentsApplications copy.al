report 50107 "WDC update "
{

    dataset
    {


        dataitem("DetCustLedgEntry"; "Detailed Cust. Ledg. Entry")
        {

            RequestFilterFields = "Entry No.", "Entry Type", "Document No.", "Document Type";

            trigger OnAfterGetRecord()
            var
                lDetCustLegEntry: Record "Detailed Cust. Ledg. Entry";
                lCustLegEntry: Record "Cust. Ledger Entry";
            begin
                // lDetCustLegEntry.Reset();
                // lDetCustLegEntry.SetRecFilter();
                // if lDetCustLegEntry.FindFirst() Then begin
                //     if DetCustLedgEntry."Amount (LCY)" <> 0 Then
                //         lDetCustLegEntry."Amount (LCY)" := DetCustLedgEntry."Amount (LCY)";


                //end;
                DetCustLedgEntry.Delete();
            end;
        }
        dataitem("CustLedgEntry"; "Cust. Ledger Entry")
        {

            RequestFilterFields = "Entry No.", "Document No.", "Document Type";

            trigger OnAfterGetRecord()
            var
                lDetCustLegEntry: Record "Detailed Cust. Ledg. Entry";
                lCustLegEntry: Record "Cust. Ledger Entry";
            begin

            end;
        }

    }

    var
        Open: Boolean;
        AmountLCY: Decimal;
        customerNo: Code[20];


}

