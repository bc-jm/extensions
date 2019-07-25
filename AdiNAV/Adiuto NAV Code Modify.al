codeunit 75001 "Adiuto Event Handler"
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'Print Confirmation', true, true)]
    procedure OnAfterActionEvent(Rec: Record "Sales Header");
    var
        lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
    begin
        lCduAdiutoDocuments.InsertDocFromVariantRecDocumentType(Rec."Document Type", Rec);
    end;
}


pageextension 75200 AdiutoGetDocument extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Navigation)
        {
            Action(ViewDocs)
            {
                CaptionML = ENU = 'View Document', ITA = 'Apri Documento';

                trigger OnAction();
                var
                    lCduAdiutoDocument: Codeunit "Adiuto Documents ED";
                begin
                    lCduAdiutoDocument.ViewDocumentsFromVariantRec(Rec."Document Type", Rec);
                end;
            }
        }

    }

}