import { LightningElement, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import OPPORTUNITY_OBJECT from "@salesforce/schema/Opportunity";

import getAccounts from '@salesforce/apex/AccountOverviewController.getAccounts';

export default class AccountsOverview extends LightningElement {

    accounts = [];
    accountLabels = {};
    contactLabels = {};
    opportunityLabels = {};
    showSpinner = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountInfo({ data, error }) {
        console.log('accInfo', data);
        if (data) this.accountLabels = {
            annualRevenue: data.fields.AnnualRevenue.label,
            businessUsers: data.fields.Business_Users__c.label,
            decisionMakers: data.fields.Decision_Makers__c.label,
            name: data.fields.Name.label,
            tickerSymbol: data.fields.TickerSymbol.label,
        }
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo({ data, error }) {
        console.log('contactInfo', data);
        if (data) this.contactLabels = {
            createdDate: data.fields.CreatedDate.label,
            name: data.fields.Name.label,
        }
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    opportunityInfo({ data, error }) {
        console.log('opportunityInfo', data);
        if (data) this.opportunityLabels = {
            amount: data.fields.Amount.label,
            name: data.fields.Name.label,
        }
    }

    async connectedCallback() {
        this.loadRecords();
    }

    loadRecords() {
        this.showSpinner = true;
        getAccounts()
            .then(result => {
                this.accounts = [];
                result.forEach(account => {
                    let accountModified = {...account};
                    accountModified.Contacts = account.Contacts?.map(contact => {
                        const url = `/${contact.Id}`;
                        return {...contact, url};
                    })
                    accountModified.Opportunities = account.Opportunities?.map(opportunity => {
                        const url = `/${opportunity.Id}`;
                        return {...opportunity, url};
                    })
                    this.accounts.push(accountModified);
                })
            })
            .catch(error => {
                // This is a bad error handling
                console.log(`ERROR: `, error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
}