pageextension 50108 "WDC Customer myList" extends "Customer List" //22
{
    actions
    {
        addfirst(processing)
        {


            // addbefore("Customer - Order Summary")
            // {
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
        }
        //}
    }
}
