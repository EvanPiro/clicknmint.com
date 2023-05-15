# Netlify Functions

Ensure the site is registered or else you won't be able to test the front-end with functions on local:
```shell
netlify init
```

To create a function, install it:
```shell
npm install @netlify/functions
```

Then make a typescript module in the following locations that will implement the handler:
```
./netlify/functions/api-method.ts
```


The URL that will call that function is:
```
/.netlify/functions/api-method
```

The code of the function for an HTTP request should look like the following:
```typescript
import { Handler, HandlerEvent, HandlerContext } from "@netlify/functions";

const handler: Handler = async (event: HandlerEvent, context: HandlerContext) => {
  return {
    statusCode: 200,
    body: JSON.stringify({name: "hello response"})
  };
};

export { handler };
```

## Environment Variables
Following a dotenv driven approach, you can load config from .env on local, and configure production env vars in the browser netlify.

## AWS
Due to netlify largely being a repackaging of AWS, certain env car key names are not allowed. You must do something the following in `.env`:
```
MY_AWS_SECRET_ACCESS_KEY="key here"
MY_AWS_ACCESS_KEY_ID="id here"
```

And then loading the configuration in the function like so:
```typescript
import * as dotenv from "dotenv";

dotenv.config();

const region = "us-east-1";

const client = new DynamoDBClient({
  region,
  credentials: {
    accessKeyId: process.env.MY_AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.MY_AWS_SECRET_ACCESS_KEY,
  },
});
```