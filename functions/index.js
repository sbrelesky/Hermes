
const admin = require("firebase-admin");
const { Timestamp } = require("firebase-admin/firestore");
admin.initializeApp();

const functions = require("firebase-functions");
// Initialize the database
const db = admin.firestore();
// Initialize the functions
require("firebase-functions/logger/compat");

// const {onCall} = require("firebase-functions/v2/https");
// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

let stripeApiKey = process.env.STRIPEKEY;

const functionConfig = () => {
    const fs = require('fs');
    return JSON.parse(fs.readFileSync('.env.json'));
};

const stripe = require('stripe')("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");


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.getStripeSecretKey =  functions.https.onCall((data, context) => {
    return {
        key: functionConfig().stripesecretkeys.key
    };
});

exports.getStripePublishableKey =  functions.https.onCall((data, context) => {
    return {
        key: functionConfig().stripepublishablekeys.key
    };
});

exports.hello = functions.https.onRequest((request, response) => {
    response.send(`NODE: ${process.env.NODE_ENV}, STRIPEKEY: ${process.env.STRIPEKEY}`);
});

const usersCollection = db.collection('User');
const fillUpsCollection = db.collection('FillUps');

exports.sendDailyNotification = functions.pubsub.schedule('every day 19:00').timeZone('America/Los_Angeles').onRun(async (context) => {

    try {        
        
        // Get tomorrow's date and time
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);

        // Query where the selected fill up date is tomorrow (overnight tonight)
        const snapshot = await fillUpsCollection
        .where("date", "==", tomorrow)
        .get();

        // Iterate through the documents and send notifications
        snapshot.forEach((doc) => {
            const fillUpData = doc.data();

            if (fillUpData.deviceToken) {

                // Construct notification message
                const message = {
                    notification: {
                        title: 'Daily Fill-Up Reminder',
                        body: `Don't forget your fill up is scheduled for tonight! Please open app to see instructions`
                    },
                    token: fillUpData.deviceToken // Assuming device token is stored in the document
                };

                // Send the notification
                admin.messaging().send(message)
                    .then((response) => {
                        console.log('Notification sent successfully:', response);
                    })
                    .catch((error) => {
                        console.error('Error sending notification:', error);
                    });
            }

        });

        return null; // All notifications sent successfully
    } catch (error) {

    }


});

exports.sendNotificationOnStatusChange = functions.firestore
.document('FillUps/{fillUpId}')
.onUpdate((change, context) => {
    
    const oldData = change.before.data();
    const newData = change.after.data();

    if (oldData.status == 'open' && newData.status == 'complete' && newData.deviceToken) {
        // Fill up was just completed

        // Construct the notification message
        const message = {
            notification: {
                title: 'Fill Up Completed!',
                body: 'Your fill up was just completed. Enjoy a hassle free full tank of gas.'
            },
            token: newData.deviceToken 
        };

        // Send the notification
        admin.messaging().send(message)
        .then((response) => {
            console.log('Notification sent successfully:', response);
        })
        .catch((error) => {
            console.error('Error sending notification:', error);
            throw error;
        });
    }

    return;

});

exports.sendNotificationToAdminOnCreate = functions.firestore.document('FillUps/{fillUpId}')
.onCreate(async (snap, context) => {

    const fillUpData = snap.data();
    const date = fillUpData.date.toDate();
    const dateString = formatDate(date);

    try {
        // Pull all the admins
        const admins = await usersCollection.where("type", "==", "admin").get();
        
        admins.forEach(adminUser => {
            const userData = adminUser.data();
            const deviceToken = userData.deviceToken;
      
            console.log(`Sending Notification to: ${userData.firstName}: ${deviceToken}`);

            if (deviceToken) {
                // Construct the notification message
                const message = {
                    notification: {
                        title: 'New Fill Up Scheduled!',
                        body: `A fill up was just scheduled for ${dateString}.`
                    },
                    token: deviceToken 
                };

                // Send the notification
                admin.messaging().send(message)
                .then((response) => {
                    console.log('Notification sent successfully:', response);
                })
                .catch((error) => {
                    console.error('Error sending notification:', error);
                    throw error;
                });
            } else {
              console.log('No device token found for user admin');
            }
        });

        return;

    } catch (error) {
        console.error(error);
        throw error;
    }

});


exports.createStripeCustomer = functions.https.onCall(async (data, context) => {
    try {
        // Ensure the user is authenticated
        console.log("Calling Create Customer: ", context.auth.uid);

        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
        }

        // Retrieve the Stripe customer ID from Firestore
        const uid = context.auth.uid;
        const userDoc = await usersCollection.doc(uid).get();
        const userData = userDoc.data();
        const email = userData.email;
        const name = userData.firstName;

        const customerData = {
            name: name,
            email: email
        };

        // Retrieve the Stripe customer from the Stripe API
        const customer = await stripe.customers.create(customerData);

        await userDoc.ref.update({stripeCustomerId: customer.id});
        
        // Return the customer data
        return customer;

    } catch (error) {
        console.error(error);
        throw error;
    }
});

exports.retrieveStripeCustomer = functions.https.onCall(async (data, context) => {
    try {
        // Ensure the user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
        }

        // Retrieve the Stripe customer ID from Firestore
        const uid = context.auth.uid;
        const userDoc = await usersCollection.doc(uid).get();
        const userData = userDoc.data();
        const stripeCustomerId = userData.stripeCustomerId;

        if (!stripeCustomerId) {
            throw new functions.https.HttpsError('not-found', 'Stripe customer ID not found for the user.');
        }

        // Retrieve the Stripe customer from the Stripe API
        const customer = await stripe.customers.retrieve(stripeCustomerId);

        console.log(customer);
        
        // Return the customer data
        return customer;

    } catch (error) {
        // Handle errors
        throw new functions.https.HttpsError('internal', 'Error retrieving Stripe customer.', error);
    }
});

exports.createPaymentMethod = functions.https.onCall(async (data, context) => {
    console.log("Create Payment Method Called");

    try {
        // Ensure the user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
        }

        const uid = context.auth.uid;
        const userDoc = await usersCollection.doc(uid).get();
        const userData = userDoc.data();
        const stripeCustomerId = userData.stripeCustomerId;


        if (!stripeCustomerId) {
            throw new functions.https.HttpsError('not-found', 'Stripe customer ID not found for the user.');
        }

        const paymentMethodId = data.paymentMethodId;

        const paymentMethod = await stripe.paymentMethods.attach(paymentMethodId, { customer: stripeCustomerId });

        const paymentMethods = await fetchPaymentMethods(stripeCustomerId);

        if (paymentMethods.length == 1) {
            console.log("Setting payment method as default");
            // We should make this the default since it's the only one
            // Set default payment method
            await stripe.customers.update(
                stripeCustomerId,
                {
                    invoice_settings: {
                        default_payment_method: paymentMethodId,
                    },
                }
            );
        } else {
            console.log("More than one payment method exists: ");
            console.log(paymentMethods);
        }

        console.log("Successfully attached payment method to customer");

        
        return paymentMethod;

    } catch (error) {
        console.error('Error creating payment method: ', error);
        throw error;
    }
});

exports.createEphemeralKey = functions.https.onCall(async (data, context) => {
    console.log("Create Ephemeral Key Method Called");

    try {

        // Ensure the user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
        }

        const uid = context.auth.uid;
        const userDoc = await usersCollection.doc(uid).get();
        const userData = userDoc.data();
        const stripeCustomerId = userData.stripeCustomerId;


        if (!stripeCustomerId) {
            throw new functions.https.HttpsError('not-found', 'Stripe customer ID not found for the user.');
        }

       const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: stripeCustomerId },
            { apiVersion: '2023-10-16'}
        );

        return {
            ephemeralKey: ephemeralKey.secret
        };

    } catch (error) {
        console.error(error);
        throw error;
    }

});

// Scheduling Fill Up Charging Customer
exports.createPaymentIntentForFillUp = functions.https.onCall(async (data, context) => {
    try {

        // Ensure the user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
        }

        // Retrieve the Stripe customer ID from Firestore
        const uid = context.auth.uid;
        const userDoc = await usersCollection.doc(uid).get();
        const userData = userDoc.data();
        const stripeCustomerId = userData.stripeCustomerId;
 
        if (!stripeCustomerId) {
            throw new functions.https.HttpsError('not-found', 'Stripe customer ID not found for the user.');
        }

        const amount = data.amount;

        const paymentIntentData = {
            amount: amount,
            currency: "usd",
            customer: stripeCustomerId,
            setup_future_usage: "on_session"
        };


        const ephemeralKey = await stripe.ephemeralKeys.create(
            {customer: stripeCustomerId},
            {apiVersion: '2023-10-16'}
        );

        const paymentIntent = await stripe.paymentIntents.create(paymentIntentData);
        const timestamp = Date.now();
        
        return { 
            date: timestamp,
            clientSecret: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customerId: stripeCustomerId,
            amount: amount,
            id: paymentIntent.id
        };
    } catch (error) {
        console.error('Error Creating payment intent: ', error);
        throw error;
    }

});

// Admin Charging the Customer
exports.createPaymentIntentForCustomer = functions.https.onCall(async (data, context) => {
    try {
        // Ensure the user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
        }

        // Retrieve the Stripe customer ID from Firestore
        const stripeCustomerId = data.customerId;

        //const fillUpId = data.fillUpId;
 
        if (!stripeCustomerId) {
            throw new functions.https.HttpsError('not-found', 'Stripe customer ID not found for the user.');
        }

        // Need the id of the payment method
        // payment_method: "pm_1OrTJXBkajlE0NzvNwlNzXVC",

        const amount = data.amount;

        const paymentIntentData = {
            amount: amount,
            currency: "usd",
            customer: stripeCustomerId,
            setup_future_usage: "on_session"
        };


        const ephemeralKey = await stripe.ephemeralKeys.create(
            {customer: stripeCustomerId},
            {apiVersion: '2023-10-16'}
        );

        const paymentIntent = await stripe.paymentIntents.create(paymentIntentData);
        const timestamp = Timestamp.now();
        
        return { 
            date: timestamp,
            clientSecret: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customerId: stripeCustomerId,
            amount: amount,
            id: paymentIntent.id
          }


    } catch (error) {
        console.error('Error Creating payment intent: ', error);
        throw error;
    }
});


// exports.fetchPaymentIntentForFillUp = functions.https.onCall(async (data, context) => {

//     try {
//         if (!context.auth) {
//             throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
//         }

//         const fillUpId = data.fillUpId;
//         const fillUp = await fillUpsCollection.doc(fillUpId).get();
//         const paymentIntentId = fillUp.data().paymentIntentId;

//         if (!paymentIntentId) {
//             throw new functions.https.HttpsError('not-found', 'Payment Intent Id not found.');
//         }

//         // Fetch the PaymentIntent
//         const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

//         // Return the PaymentIntent
//         return paymentIntent;

//     } catch (error) {
//         console.error('Error fetching PaymentIntent:', error);
//         throw error;
//     }
// });

// Create a setup intent for managing payment methods
exports.createSetupIntent = functions.https.onCall(async (data, context) => {
    try {
        // Check authentication
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
        }

        // Retrieve the Stripe customer ID from Firestore
        const uid = context.auth.uid;
        const userDoc = await usersCollection.doc(uid).get();
        const userData = userDoc.data();
        const stripeCustomerId = userData.stripeCustomerId;


        // Create SetupIntent
        const setupIntent = await stripe.setupIntents.create({
            customer: stripeCustomerId, // Customer ID
        });

        // Return SetupIntent ID
        return setupIntent;

    } catch (error) {
        // Handle errors
        console.error('Error creating SetupIntent:', error);
        throw error;
    }
});

exports.retrievePaymentMethods = functions.https.onCall(async (data, context) => {
    // Check if the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
    }

    try {
        // Retrieve the Stripe customer ID from Firestore
        const uid = context.auth.uid;
        const userDoc = await usersCollection.doc(uid).get();
        const userData = userDoc.data();
        const stripeCustomerId = userData.stripeCustomerId;

        // Retrieve the payment methods associated with the customer from Stripe
        const paymentMethods = await fetchPaymentMethods(stripeCustomerId);

        // Return the list of payment methods
        return paymentMethods;
    } catch (error) {
        console.error('Error retrieving payment methods:', error);
        throw new functions.https.HttpsError('internal', 'An error occurred while retrieving payment methods. Please try again later.');
    }
});

exports.retrievePaymentMethodForPaymentIntent = functions.https.onCall(async (data, context) => {

    // Check if the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
    }

    try {
        // Retrieve the Stripe customer ID from Firestore
        const paymentIntentId = data.paymentIntentId;

        // Retrieve the payment methods associated with the customer from Stripe
        const paymentMethods = await fetchPaymentMethods(stripeCustomerId);

        // Return the list of payment methods
        return paymentMethods;
    } catch (error) {
        console.error('Error retrieving payment methods:', error);
        throw new functions.https.HttpsError('internal', 'An error occurred while retrieving payment methods. Please try again later.');
    }
});

exports.cancelFillUp = functions.https.onCall(async (data, context) => {

        // Check if the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to access this resource.');
    }

    const fillUpId  = data.fillUpId;
    const paymentIntentId = data.paymentIntentId;    

    try {
        // Refund payment intent
        const refund = await stripe.refunds.create({
            payment_intent: paymentIntentId,
            reason: "requested_by_customer"
        });

        // Update fill up document with refund status
        await fillUpsCollection.doc(fillUpId).update({ 
            status: "refunded", 
            refund: refund
        });

        console.log('Refund processed successfully:', refund.id);
        return;
    } catch (error) {
        console.error('Error processing refund:', error);
        throw error;
    }
});


async function fetchPaymentMethods(customerId) {
    
    try {
         // Retrieve the payment methods associated with the customer from Stripe
         const paymentMethods = await stripe.paymentMethods.list({
            customer: customerId,
            type: 'card',
        });

        return paymentMethods.data;

    } catch (error) {
        throw error;
    }
}

// Function to format date as 'Wednesday, July 21, 2024'
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric'
    });
}
