pageextension 50108 "WDC Customer List" extends "Customer List" //22
{
    actions
    {
        addfirst(processing)
        {
            action(WDC_CustomerPaymentsTracking)
            {
                ApplicationArea = All;
                Caption = 'Customer Payments Tracking';
                Image = PaymentForecast;
                RunObject = report "WDC Customer Payments Tracking";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

            }
            action(WDC_CustomerInvByCHQ)
            {
                ApplicationArea = All;
                Caption = 'Customer Invoices By Cheque';
                Image = PaymentJournal;
                RunObject = report "WDC Customer Inv. by Cheque";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

            }
            action(WDC_Total_BySales_Person)
            {
                ApplicationArea = All;
                Caption = 'Total by Sales Serson';
                Image = PaymentHistory;
                RunObject = report "WDC Total by Sales Person";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

            }
        }
    }
}
