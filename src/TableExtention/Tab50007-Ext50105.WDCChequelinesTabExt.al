tableextension 50105 "WDC ChequelinesTabExt" extends "Cheque Line" //50007
{
    fields
    {
        field(50200; "Amt(LCY) Not Applied"; Decimal)
        {
            Editable = False;
            FieldClass = FlowField;
            CalcFormula = lookup("Cust. Ledger Entry"."Amt(LCY) Not Applied" where("Document No." = field("Invoice No."),
                                                                              "Document Type" = filter(Invoice)));

        }
    }
}