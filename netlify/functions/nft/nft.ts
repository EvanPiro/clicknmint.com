import { Handler, HandlerEvent, HandlerContext } from "@netlify/functions";

const handler: Handler = async (
  event: HandlerEvent,
  context: HandlerContext
) => {
  return {
    statusCode: 200,
    body: JSON.stringify({ name: "hello nft response" }),
  };
};

export { handler };
