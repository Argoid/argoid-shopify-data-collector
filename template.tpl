___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.

___INFO___

{
  "displayName": "Argoid Events Collector",
  "categories": ["PERSONALIZATION", "ANALYTICS"],

}


{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Argoid GTM Clickstream",
  "brand": {
    "id": "brand_dummy",
    "displayName": "Argoid"
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "templateVariable",
    "displayName": "Argoid Analytics Settings Imported Template Variable Name",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const argoidRestBaseUrl = data.templateVariable.appSettings.eventServerUrl;
const callInWindow = require("callInWindow");
const copyFromWindow = require("copyFromWindow");
const queryPermission = require("queryPermission");
const encodeUriComponent = require("encodeUriComponent");
const log = require("logToConsole");
const makeInt = require("makeInteger");
const getTimestampMillis = require("getTimestampMillis");
const sendPixel = require("sendPixel");
const injectScript = require("injectScript");
const script_url ="https://storage.googleapis.com/common-scripts/basicMethods.js";
const Math = require('Math');
const deviceInfo = data.templateVariable.deviceInfo;
const currentUrlSplit = data.templateVariable.pageView.currentUrl.split("/");
let timestamp = getTimestampMillis().toString();
let browser = "null";
let nAgt = deviceInfo.argoidDeviceInfo.browserUserAgent;
var eventServerRequestHeaders = [];
var verOffset, nameOffset , cartData;
var isProduct = currentUrlSplit[3];
var cartData = data.templateVariable.cart.cartData;
var cartEvent= data.templateVariable.cart.cartEvent;

const FinalData = {
  sessionId: deviceInfo.argoidSessionIdValue,
  userIds: {
    anonymousId: data.templateVariable.user.gaId,
    registeredUserId: data.templateVariable.user.userId,
  },
  appId: data.templateVariable.appSettings.appId,
  appSource: data.templateVariable.appSettings.appSource,
  eventTimestamp: timestamp,
  eventType: "not defined",
  eventAttributes: "not defined",
  deviceAttributes: data.templateVariable.deviceInfo.argoidDeviceInfo,
  clientAttributes: {
    appVersion: data.templateVariable.appSettings.appVersion,
    sdkVersion: data.templateVariable.appSettings.sdkVersion,
    shopifyVariable:data.templateVariable.shopifyVariable
  },
  additionalMetadata: { status: "SUCCESS" },
};

function logger(){
  log("anonymousId =", data.templateVariable.user.gaId);
  log("registeredUserId =", data.templateVariable.user.userId);
  log("appId =", data.templateVariable.appSettings.appId);
  log("appSource =", data.templateVariable.appSettings.appSource);
  log("eventTimestamp =", timestamp);
  log("deviceInfo",data.templateVariable.deviceInfo.argoidDeviceInfo);
  log("browser =", browser);
  log("appVersion =", data.templateVariable.appSettings.appVersion);
  log("sdkVersion =", data.templateVariable.appSettings.sdkVersion);
  log("ShopifyVariable",data.templateVariable.appSettings.shopifyVariable);
}

function generatingCartData() {
  var jsonData = cartData;
  var event= cartEvent;
  var discount_percentage;
  var data;
  if(event=="argoid_add_to_cart" && jsonData.items != null)
  {
              
    var line_items=[];
    for(var i=0;i<jsonData.items.length;i++)
    {
       discount_percentage = (((makeInt(jsonData.items[i].original_price/100)) - (makeInt(jsonData.items[i].final_price/100))) / (makeInt(jsonData.items[i].original_price/100))) * 100.0;
	  	discount_percentage = (Math.round(discount_percentage, 0));
      
           line_items.push({
             "productGroupId": "gid://shopify/Product/"+jsonData.items[i].product_id,
             "productVariantId": "gid://shopify/ProductVariant/"+jsonData.items[i].variant_id,
             "quantity" : jsonData.items[i].quantity,
             "actualPrice": (jsonData.items[i].original_price/100).toString(),
             "finalPrice": (jsonData.items[i].final_price/100).toString(),
             "discount": [{"percentage":discount_percentage.toString()}]
               }
            );
    }
     data = {  
      "lineItems":line_items
  };
    return data;
}  
  else if(event=="argoid_add_to_cart" && jsonData.items == null){
    
        discount_percentage = (((makeInt(jsonData.original_price/100)) - (makeInt(jsonData.final_price/100))) / (makeInt(jsonData.original_price/100))) * 100.0;
	  	discount_percentage = (Math.round(discount_percentage, 0));
        data = {  
      "lineItems": [{
              "productGroupId": "gid://shopify/Product/"+jsonData.product_id,
              "productVariantId": "gid://shopify/ProductVariant/"+jsonData.variant_id,
              "quantity" : jsonData.quantity,
               "actualPrice": (jsonData.original_price/100).toString(),
               "finalPrice": (jsonData.final_price/100).toString(),
               "discount": [{"percentage":discount_percentage.toString()}]
               }]
  };
    return data;
}
}

function addHeaders(){
  data.templateVariable.appSettings.eventServerAuthorization.forEach(function (
    serverAuth
  ) {
    log("serverAuth", serverAuth);
    if (serverAuth.enabled) {
      eventServerRequestHeaders.push(serverAuth.header);
    }
  });
}

function whichBrowser(){
  // Opera
  if ((verOffset = nAgt.indexOf("Opera")) != -1) {
    browser = "Opera";
  }
  // MSIE
  else if ((verOffset = nAgt.indexOf("MSIE")) != -1) {
    browser = "Microsoft Internet Explorer";
  }
  // Chrome
  else if ((verOffset = nAgt.indexOf("Chrome")) != -1) {
    browser = "Chrome";
  }
  // Safari
  else if ((verOffset = nAgt.indexOf("Safari")) != -1) {
    browser = "Safari";
  }
  // Firefox
  else if ((verOffset = nAgt.indexOf("Firefox")) != -1) {
    browser = "Firefox";
  }
  // MSIE 11+
  else if (nAgt.indexOf("Trident/") != -1) {
    browser = "Microsoft Internet Explorer";
  }
  // Other browsers
  else if (
    (nameOffset = nAgt.lastIndexOf(" ") + 1) < (verOffset = nAgt.lastIndexOf("/"))
  ) {
    browser = nAgt.substring(nameOffset, verOffset);
}
}

function isObjectEmpty(obj) {
  if (
    obj == "undefine" ||
    obj == "undefined" ||
    obj == "null" ||
    obj == undefined ||
    obj == null ||
    obj == " "
  ) {
    return true;
  }
  return false;
}

function sendingDataToServer(source) {
  log("calling injectingScript , source = ",source);
  if (queryPermission("inject_script", script_url)) {
    injectScript(
      script_url,
      () => {
        log("sending events to  server");
        var sentFnReturnVal = callInWindow(
          "sendRequest",
          "POST",
          argoidRestBaseUrl,
          FinalData,
          eventServerRequestHeaders
        );
      },
      (err) => {
        log("error while injecting script", err);
      }
    );
  } else {
    log("not injecting Script");
  }
}

function validatingAddToCartData() {
    log("validating cart data");
  var errors = [];
  if (
    isObjectEmpty(FinalData.userIds.anonymousId) &&
    isObjectEmpty(FinalData.userIds.registeredUserId)
  ) {
    errors.push("Unable to anonymousId / registeredUserId");
  }

  if (isObjectEmpty(cartData)) {
    errors.push("Unable to get the Added Cart Data");
  } else if (
    isObjectEmpty(cartData.lineItems) ||
    isObjectEmpty(
      cartData.lineItems[0].quantity
    ) ||
    (isObjectEmpty(
      cartData.lineItems[0].productGroupId
    ) &&
      isObjectEmpty(
        cartData.lineItems[0].productVariantId
      ))
  ) {
    if (isObjectEmpty(cartData.lineItems)) {
      errors.push("Unable to get the lineItems");
    }
    if (
      isObjectEmpty(
        cartData.lineItems[0].quantity
      )
    ) {
      errors.push("Unable to get the lineItems 0 quantity");
    }
    if (
      isObjectEmpty(
        cartData.lineItems[0].productGroupId
      ) &&
      isObjectEmpty(
        cartData.lineItems[0].productVariantId
      )
    ) {
      errors.push(
        "Unable to get the lineItems 0  productGroupId or productVariantId"
      );
    }
  }
  if (errors.length >= 1) {
    FinalData.additionalMetadata = { status: "FAILURE", errors: errors };
  }
}


function eventConditional(){
  log("enter conditional block");
  
if (data.templateVariable.cart.cartEvent == "argoid_add_to_cart" &&
  data.templateVariable.cart.cartEvent != "gtm.pageError" &&  data.templateVariable.cart.addToCardObj !="null") {
    log("argoid ADD_PRODUCT_TO_CART start");
    cartData = generatingCartData();
    FinalData.eventAttributes = cartData;
    FinalData.eventType = "ADD_PRODUCT_TO_CART";
    validatingAddToCartData();
    sendingDataToServer("ADD_PRODUCT_TO_CART");
    log("argoid ADD_PRODUCT_TO_CART end");
}
  
  if(
    isProduct == "products" &&
    data.templateVariable.cart.cartEvent != "gtm.click" &&
    data.templateVariable.cart.cartEvent != "gtm.pageError" &&
    data.templateVariable.cart.cartEvent != "cart_summery" &&
    data.templateVariable.cart.cartEvent != "argoid_add_to_cart"
  ) {
    log("Enter view product");
    const viewProductData = {
      productGroupId: data.templateVariable.pageView.productPage.productId
    };
      FinalData.eventAttributes = viewProductData;
      FinalData.eventType = "VIEW_PRODUCT";
      log("Sending VIEW_PRODUCT event");
      log(data.templateVariable.pageView.sourcePageUrl);
      sendingDataToServer("VIEW_PRODUCT");
  } 
}

logger();
addHeaders();
whichBrowser();
eventConditional();
data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "sendPOST.sendEvent"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "sendRequest"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://*.free.beeceptor.com/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://storage.googleapis.com/common-scripts/basicMethods.js"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 11/08/2022, 10:37:07


