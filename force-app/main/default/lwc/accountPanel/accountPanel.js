import { LightningElement, api } from "lwc";

export default class AccountPanel extends LightningElement {

    @api account;
    @api accountLabels;
    @api contactLabels;
    @api opportunityLabels;

    contactsColumns = [
        { label: this.contactLabels?.name || 'Name', fieldName: 'url', type: 'url', typeAttributes: { label: { fieldName: 'Name', target: '_blank' }} },
        { label: this.contactLabels?.createdDate || 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    ];

    opportunitiesColumns = [
        { label: this.opportunityLabels?.name || 'Name', fieldName: 'url', type: 'url', typeAttributes: { label: { fieldName: 'Name', target: '_blank' }} },
        { label: this.opportunityLabels?.amount || 'Amount', fieldName: 'Amount', type: 'currency' },
    ];

    formattedLabels = {
        annualRevenue: this.accountLabels?.annualRevenue || 'Annual Revenue',
        contactRelations: 'Contact Relations',
        contacts: 'Contacts',
        opportunities: 'Opportunities',
        tickerSymbol: this.accountLabels?.tickerSymbol || 'Ticker Symbol',
    };

    get accountUrl() {
        return '/' + this.account.Id;
    }
}