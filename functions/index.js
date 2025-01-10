
const admin = require("firebase-admin");
const { ServerValue } = require("firebase-admin/database");
const { Timestamp } = require("firebase-admin/firestore");
const functions = require("firebase-functions");
const axios = require('axios');
const nodemailer = require('nodemailer');

require("firebase-functions/logger/compat");

admin.initializeApp();


// Initialize the database
const db = admin.firestore();


const functionConfig = () => {
    const fs = require('fs');
    return JSON.parse(fs.readFileSync('.env.json'));
};

const stripeConfig = functionConfig().stripeConfig;
const carsConfig = functionConfig().carsConfig;

const cors = require('cors')({ origin: true });
const stripe = require('stripe')(stripeConfig.stripesecretkeys.key);

// Retrieve email credentials from Firebase environment configuration
const mailEmail = functions.config().email.user;
const mailPassword = functions.config().email.pass;

const mailTransport = nodemailer.createTransport({
    service: 'aol',
    auth: {
        user: mailEmail,
        pass: mailPassword,
    },
});




// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.getStripeSecretKey = functions.https.onCall((data, context) => {
    return {
        key: functionConfig().stripesecretkeys.key
    };
});

exports.getStripePublishableKey =  functions.https.onCall((data, context) => {
    return {
        key: functionConfig().stripepublishablekeys.key
    };
});

exports.hello = functions.https.onRequest( async (request, response) => {
    const recipientEmail = 'shanebrelesky@gmail.com';
    console.log('recipientEmail: ' + recipientEmail);

    const mailOptions = {
        from: 'Hermes Fuel<hermesfuel@aol.com>',
        to: recipientEmail,
        html:
        `<html>
    <body style="font-family: 'Avenir', sans-serif;margin:0;">
        <table role="presentation" style="width: 100%; height: 300px; background-color: #eeb422; text-align: center;">
            <tr>
                <td style="vertical-align: middle;">
                    <img src="https://hermes-web-sbreleskys-projects.vercel.app/logo_text.png" alt="Hermes Logo" style="max-width: 100px; margin-bottom: 30px;">
                    <h1 style="margin: 0; color: white;">Order Confirmed!</h1>
                    <div style="margin-top: 10px; color: white;">Order #182749384983</div>
                </td>
            </tr>
        </table>
        <table role="presentation" style="width: 100%; max-width: 600px;margin: auto;">
            <tr>
                <td style="padding: 20px;">
                    <div id="content">
                        <div style="color: #274653; font-size: 22px;font-weight: bold;margin-bottom: 0px;">Shane, thank you so much for your order!</div>
            
                        <div id="instructions-container">
                            <p style="margin-top: 0px;color: gray; font-size: 14px;">Please make sure to follow the instructions below in order to make this process as seemless as possible.</p>
                            <div><h3 style="margin-bottom: 0px; color: #274653;">1. Move Your Car</h3><p style="font-size: 12px;margin-top: 0px;">Remember to leave your car in an easily accessible space.</p></div>
                            <div><h3 style="margin-bottom: 0px; color: #274653;">2. Open Gas Cap Cover</h3><p style="font-size: 12px;margin-top: 0px;">Please make sure to unlock the gas cap cover if necessary.</p></div>
                            <div><h3 style="margin-bottom: 0px; color: #274653;">3. Enjoy</h3><p style="font-size: 12px;margin-top: 0px;">Enjoy a hassle free filled gas tank!</p></div>
                        </div>
                            
                        <hr style="color: #274653; opacity: 0.3;">
            
                        <div style="color: gray; font-size: 22px;font-weight: bold; margin-top: 20px; margin-bottom: 0px;">Order Details</div>
            
                        <label style="font-weight: bold;margin-bottom: 0px; color: #274653;">Date:</label>
                        <p style="margin-top: 0px;">Friday, June 3, 2024</p>
                        <label style="font-weight: bold;margin-bottom: 0px; color: #274653;">Address:</label>
                        <p style="margin-top: 0px;">3788 Elliot St Apt 19, San Diego, CA, 92106</p>
                        <label style="font-weight: bold;margin-bottom: 0px; color: #274653;">Your Order:</label>
                        <div id="order-summary">
                            <div>2010</div>
                            <div>BMW - 3 Series</div>
            
                            <div>
                                $40.00
                            </div>
                        </div>
            
                        <div id="order-container" style="margin-top: 20px;">
                            <div style="float: left; width: 48%; color: #274653;">
                                <label style="font-weight: bold; margin-bottom: 0px;">Payment Method:</label>
                                <div>Credit Card - Visa</div>
                            </div>
                            <div style="float: right; width: 48%; text-align: right;">
                                <div>Gas Total: $40.00</div>
                                <div>Service Fee: $10.00</div>
                                <div>Total: $50.00</div>
                            </div>
                            <div style="clear: both;"></div>
                        </div>

                        <hr style="color: #274653; opacity: 0.3;">
                        <div style="margin-top: 0px;color: gray; font-size: 14px;">
                            <p>If you have any questions at all, feel free to reach out to our support by <a style="color: #eeb422;" href= "mailto: hermesfuel@aol.com">Email</a>.</p>
                            <div>Thanks,</div> 
                            <div>Hermes Team</div>
                        </div> 
                           
                    </div>    
                </td>
            </tr>
        </table>
    </body>       
</html>`
    };

    mailOptions.subject = 'Hermes Fill-Up Reminder';

    try {
        await mailTransport.sendMail(mailOptions);
        response.send({ success: true, from: mailEmail, recipient: recipientEmail});
    } catch (error) {
        console.error('Error sending email:', error);
        response.status(500).send({ success: false, error: error.toString(), from: mailEmail,  recipient: recipientEmail});
    }

});

const usersCollection = db.collection('User');
const fillUpsCollection = db.collection('FillUps');

exports.sendDailyNotification = functions.pubsub.schedule('every day 19:00').timeZone('America/Los_Angeles').onRun(async (context) => {

    try {        
        
        // Create a new Date object
        let tomorrow = new Date();
        // Move to the next day
        tomorrow.setDate(tomorrow.getDate());
        // Set the timezone offset to Pacific Time (PT), the Server Time
        tomorrow.setUTCHours(7); // Assuming Pacific Time is UTC-7
        // Set hours, minutes, seconds, and milliseconds to midnight
        tomorrow.setUTCMinutes(0);
        tomorrow.setUTCSeconds(0);
        tomorrow.setUTCMilliseconds(0);

        console.log("Check for Fill Ups Tomorrow: ", tomorrow);

        // Query where the selected fill up date is tomorrow (overnight tonight)
        const snapshot = await fillUpsCollection
        .where("date", "==", tomorrow)
        .get();

        // Iterate through the documents and send notifications
        snapshot.forEach(async (doc) => {
            const fillUpData = doc.data();
            const userData = fillUpData.user;
            const uid = userData.id; 
            

            if (userData.isWebOnly) {
                // Send email
                
            } else {
                // Send push notification
                let deviceToken = userData.deviceToken;

                if (!deviceToken) {
                    const userDoc = await usersCollection.doc(uid).get();
                    deviceToken = userDoc.data().deviceToken;
                }

                if (deviceToken) {

                    // Construct notification message
                    const message = {
                        notification: {
                            title: 'Daily Fill-Up Reminder',
                            body: `Don't forget your fill up is scheduled for tonight! Please open app to see instructions`
                        },
                        token: deviceToken // Assuming device token is stored in the document
                    };

                    // Send the notification
                    admin.messaging().send(message)
                        .then((response) => {
                            console.log('Notification sent successfully:', uid, deviceToken);
                        })
                        .catch((error) => {
                            console.error('Error sending notification:', error);
                        });
                }
            }
            
        });

        return;

    } catch (error) {
        console.error('Error sending scheduled notification:', error);
        throw error;
    }
});

exports.sendNotificationOnStatusChange = functions.firestore
.document('FillUps/{fillUpId}')
.onUpdate(async (change, context) => {
    
    const oldData = change.before.data();
    const newData = change.after.data();

    // Fill up was just completed
    if (oldData.status == 'open' && newData.status == 'complete') {
       
        const userData = newData.user; 
        const uid = newData.user.id;

        let deviceToken = userData.deviceToken;

        if (!deviceToken) {
            const userDoc = await usersCollection.doc(uid).get();
            deviceToken = userDoc.data().deviceToken;
        }

        if (deviceToken) {
            // Construct the notification message
            const message = {
                notification: {
                    title: 'Fill Up Completed!',
                    body: 'Your fill up was just completed. Enjoy a hassle free full tank of gas.'
                },
                token: deviceToken 
            };

            // Send the notification
            admin.messaging().send(message)
            .then((response) => {
                console.log('Notification sent successfully:', uid, deviceToken);
            })
            .catch((error) => {
                console.error('Error sending notification:', error);
                throw error;
            });
        }
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

///////////////////////////////////////
///////////// WEB METHODS /////////////
///////////////////////////////////////
exports.fetchOrCreateUser = functions.https.onCall(async (data, context) => {

    const name = data.name;
    const email = data.email;

    console.log('fetchOrCreateUser called...');

    return new Promise(async (resolve, reject) => {

        try {
            console.log(`Querying Users Collection for email: ${email}`);
            // Check for a user with this email or create a new one
            const users = await usersCollection.where("email", "==", email).get();

            console.log('Users fetched:');
            console.log(users.docs.length);

            users.forEach(usr => {
                const userData = usr.data();
                console.log(userData);
            });
    
            if (users.docs.length > 1) {
                reject(new functions.https.HttpsError('abort', `Found more than one user with email: ${email}`));
            }
    
            if (users.docs.length == 0) {

                console.log("Creating new user");
                // Create a new user
                const userData = {
                    email: email,
                    firstName: name,
                    isWebOnly: true
                };
        
                const newUserRef = await usersRef.add(userData);
                const newUserDoc = await newUserRef.get();
                resolve(newUserDoc.data());
    
            } else if (users.docs.length == 1){
                console.log("Returning existing user");
                resolve(users.docs[0].data());
            }
    
        } catch (error) {
            reject(error);
        }
    });
    
});


exports.createPaymentIntentServiceFee = functions.https.onCall(async (data, context) => {
    
    cors(req, res, async () => {
        try {   

            const name = data.name;
            const email = data.email;
            const amount = data.amount;

            

            const customerData = {
                name: name,
                email: email
            };
    
            // Retrieve the Stripe customer from the Stripe API
            const customer = await stripe.customers.create(customerData);
    
            console.log("Customer Created: ", customer.id);
        
            const paymentIntentData = {
                amount: amount,
                currency: "usd",
                customer: customer.id
            };
    
            const paymentIntent = await stripe.paymentIntents.create(paymentIntentData);
            const timestamp = Date.now();
            
            return { 
                date: timestamp,
                clientSecret: paymentIntent.client_secret,
                customerId: customer.id,
                amount: amount,
                id: paymentIntent.id
            };
    
        } catch (error) {
            console.error('Error Creating payment intent: ', error);
            throw error;
        }
    });
});

exports.createStripePaymentElement = functions.https.onCall(async (data, context) => {
    
    const clientSecret = data.clientSecret;
    const loader = data.loader;

    const elements = stripe.elements({ clientSecret, loader });
    const paymentElement = elements.create('payment');

    return paymentElement;
    
});

exports.fetchMakes = functions.https.onCall(async (data, context) => {
    
    console.log("fetchMakes function called...");
    return new Promise(async (resolve, reject) => {        
        const settings = {
            async: true,
            crossDomain: true,
            url: carsConfig.baseUrl + "/makes?direction=asc&sort=name",
            method: 'GET',
            headers: {
                'x-rapidapi-key': carsConfig.key,
                'x-rapidapi-host': carsConfig.host
            }
        };
    
        try {
            const response = await axios(settings);
            const data = response.data.data;
            resolve({ data })
            
        } catch (error) {
            console.error('Error fetching makes:', error);
            reject(error);
        }    
    });
});

exports.fetchModels = functions.https.onCall(async (data, context) => {
    
    const make = data.make;
    const year = data.year;

    console.log("fetchModels function called...");
    return new Promise(async (resolve, reject) => { 
        const settings = {
            async: true,
            crossDomain: true,
            url: carsConfig.baseUrl + `/models?make_id=${make}&sort=id&year=${year}&direction=asc&verbose=no`,
            method: 'GET',
            headers: {
                'x-rapidapi-key': carsConfig.key,
                'x-rapidapi-host': carsConfig.host
            }
        };
    
        try {
            const response = await axios(settings);
            const data = response.data.data;
            resolve({ data });
        } catch (error) {
            console.error('Error fetching models:', error);
            reject(error);
        }
    });
    
});


exports.fetchFuelCapacity = functions.https.onCall(async (data, context) => {
    
    const model = data.model;
    const year = data.year;

    // Fetch the fuel capacity
    const settings = {
        async: true,
        crossDomain: true,
        url: carsConfig.baseUrl + `/mileages?direction=asc&verbose=no&sort=id&year=${year}&make_model_id=${model}`,
        method: 'GET',
        headers: {
            'x-rapidapi-key': carsConfig.key,
            'x-rapidapi-host': carsConfig.host
        }
    };

    return new Promise(async (resolve, reject) => { 
        const settings = {
            async: true,
            crossDomain: true,
            url: carsConfig.baseUrl + `/mileages?direction=asc&verbose=no&sort=id&year=${year}&make_model_id=${model}`,
            method: 'GET',
            headers: {
                'x-rapidapi-key': carsConfig.key,
                'x-rapidapi-host': carsConfig.host
            }
        };
    
        try {
            const response = await axios(settings);
            console.log("Fuel Capacity Data: ", response.data);

            const data = response.data.data;

            if (data.length > 0) {
                // const fuelCapacity = data[0].fuel_tank_capacity;
                resolve({ data });
            } else {
                resolve({});
            }
        } catch (error) {
            console.error('Error fetching models:', error);
            reject(error);
        }
    });
});

 
exports.addMessage = functions.https.onCall((data, context) => {

    return new Promise(async (resolve, reject) => { 
        resolve({success: true});
    });
    
    //return {success: true};

});

exports.sendConfirmationEmail = functions.https.onCall(async (data, context) => {

    const fillUpId = data.fillUpId;

    const fillUp = await fillUpsCollection.doc(fillUpId).get();
    const fillUpData = fillUp.data();

    const recipientEmail = 'shanebrelesky@gmail.com';
    console.log('recipientEmail: ' + recipientEmail);

    const mailOptions = {
        from: 'Hermes Fuel<hermesfuel@aol.com>',
        to: recipientEmail,
        html:
        `<html>
    <body style="font-family: 'Avenir', sans-serif;margin:0;">
        <table role="presentation" style="width: 100%; height: 300px; background-color: #eeb422; text-align: center;">
            <tr>
                <td style="vertical-align: middle;">
                    <img src="https://hermes-web-sbreleskys-projects.vercel.app/logo_text.png" alt="Hermes Logo" style="max-width: 100px; margin-bottom: 30px;">
                    <h1 style="margin: 0; color: white;">Order Confirmed!</h1>
                    <div style="margin-top: 10px; color: white;">Order #182749384983</div>
                </td>
            </tr>
        </table>
        <table role="presentation" style="width: 100%; max-width: 600px;margin: auto;">
            <tr>
                <td style="padding: 20px;">
                    <div id="content">
                        <div style="color: #274653; font-size: 22px;font-weight: bold;margin-bottom: 0px;">Shane, thank you so much for your order!</div>
            
                        <div id="instructions-container">
                            <p style="margin-top: 0px;color: gray; font-size: 14px;">Please make sure to follow the instructions below in order to make this process as seemless as possible.</p>
                            <div><h3 style="margin-bottom: 0px; color: #274653;">1. Move Your Car</h3><p style="font-size: 12px;margin-top: 0px;">Remember to leave your car in an easily accessible space.</p></div>
                            <div><h3 style="margin-bottom: 0px; color: #274653;">2. Open Gas Cap Cover</h3><p style="font-size: 12px;margin-top: 0px;">Please make sure to unlock the gas cap cover if necessary.</p></div>
                            <div><h3 style="margin-bottom: 0px; color: #274653;">3. Enjoy</h3><p style="font-size: 12px;margin-top: 0px;">Enjoy a hassle free filled gas tank!</p></div>
                        </div>
                            
                        <hr style="color: #274653; opacity: 0.3;">
            
                        <div style="color: gray; font-size: 22px;font-weight: bold; margin-top: 20px; margin-bottom: 0px;">Order Details</div>
            
                        <label style="font-weight: bold;margin-bottom: 0px; color: #274653;">Date:</label>
                        <p style="margin-top: 0px;">Friday, June 3, 2024</p>
                        <label style="font-weight: bold;margin-bottom: 0px; color: #274653;">Address:</label>
                        <p style="margin-top: 0px;">3788 Elliot St Apt 19, San Diego, CA, 92106</p>
                        <label style="font-weight: bold;margin-bottom: 0px; color: #274653;">Your Order:</label>
                        <div id="order-summary">
                            <div>2010</div>
                            <div>BMW - 3 Series</div>
            
                            <div>
                                $40.00
                            </div>
                        </div>
            
                        <div id="order-container" style="margin-top: 20px;">
                            <div style="float: left; width: 48%; color: #274653;">
                                <label style="font-weight: bold; margin-bottom: 0px;">Payment Method:</label>
                                <div>Credit Card - Visa</div>
                            </div>
                            <div style="float: right; width: 48%; text-align: right;">
                                <div>Gas Total: $40.00</div>
                                <div>Service Fee: $10.00</div>
                                <div>Total: $50.00</div>
                            </div>
                            <div style="clear: both;"></div>
                        </div>

                        <hr style="color: #274653; opacity: 0.3;">
                        <div style="margin-top: 0px;color: gray; font-size: 14px;">
                            <p>If you have any questions at all, feel free to reach out to our support by <a style="color: #eeb422;" href= "mailto: hermesfuel@aol.com">Email</a>.</p>
                            <div>Thanks,</div> 
                            <div>Hermes Team</div>
                        </div> 
                           
                    </div>    
                </td>
            </tr>
        </table>
    </body>       
</html>`
    };

    mailOptions.subject = 'Hermes Fill-Up Reminder';

    try {
        await mailTransport.sendMail(mailOptions);
        response.send({ success: true, from: mailEmail, recipient: recipientEmail});
    } catch (error) {
        console.error('Error sending email:', error);
        response.status(500).send({ success: false, error: error.toString(), from: mailEmail,  recipient: recipientEmail});
    }


});