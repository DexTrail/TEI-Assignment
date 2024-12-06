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
        businessUsers: this.accountLabels?.businessUsers || 'Business Users',
        decisionMakers: this.accountLabels?.decisionMakers || 'Decision Makers',
        tickerSymbol: this.accountLabels?.tickerSymbol || 'Ticker Symbol',
    };

    get accountUrl() {
        return '/' + this.account.Id;
    }

    get contactRelationsTabTitle() {
        return `Contact Relations ${this.account?.ContactRelations?.length || 0}`;
    }

    get contactsTabTitle() {
        return `Contacts ${this.account?.Contacts?.length || 0}`;
    }

    get opportunitiesTabTitle() {
        return `Opportunities ${this.account?.Opportunities?.length || 0}`;
    }
}