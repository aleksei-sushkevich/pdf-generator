({
    handleSendEmail : function(component) {
        component.find('childlwc').sendEmail();
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "message": "Email has been sent."
        });
        resultsToast.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    init : function(component) {
        var action = component.get("c.getPdfId");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.pdfId", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})
