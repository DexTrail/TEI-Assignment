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

    get accountUrl() {
        return '/' + this.account.Id;
    }

    get annualRevenueLabel() {
        return this.accountLabels?.annualRevenue || 'Annual Revenue';
    }

    get businessUsersLabel() {
        return this.accountLabels?.businessUsers || 'Business Users';
    }

    get contactRelationsTabTitle() {
        return `Contact Relations ${this.account?.ContactRelations?.length || 0}`;
    }

    get contactsTabTitle() {
        return `Contacts ${this.account?.Contacts?.length || 0}`;
    }

    get decisionMakersLabel() {
        return this.accountLabels?.decisionMakers || 'Decision Makers';
    }

    get opportunitiesTabTitle() {
        return `Opportunities ${this.account?.Opportunities?.length || 0}`;
    }

    get tickerSymbolLabel() {
        return this.accountLabels?.tickerSymbol || 'Ticker Symbol';
    }
}