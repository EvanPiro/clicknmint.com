# Netlify Redirects

To enable a browser app to handle all the routing from the front-end, we'll need to configure the redirect to mask all the http paths beyond `/`. To do this you need to create a file called `_redirects` and set a rule like the following:
```
/* /index.html 200
```
Note that the 200 here allows the redirect to retain the same path so that the user will not lose the URL they've navigated to on refresh. All requests will go to `/` behind the scenes with the front-end only aware of the new url.