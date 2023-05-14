# Netlify Functions

To create a function, install it:
```shell
npm install @netlify/functions
```

Then make a file in the following locations
```
./netlify/functions/my-function.ts
```


The URL that will call that function is
```
/.netlify/functions/my-function.ts
```

The code of the function for an HTTP request should look like the following:
```typescript
import { Handler, HandlerEvent, HandlerContext } from "@netlify/functions";

const handler: Handler = async (event: HandlerEvent, context: HandlerContext) => {
  // your server-side functionality
};

export { handler };
```