const POLL_INTERVAL = 1000

const poll = ({ fn, validate, interval, maxAttempts }) => {
  let attempts = 0

  const executePoll = async (resolve, reject) => {
    const result = await fn()
    attempts++

    if (!interval) {
      interval = POLL_INTERVAL
    }

    if (validate && validate(result)) {
      return resolve(result)
    } else if (maxAttempts && attempts === maxAttempts) {
      return reject(new Error("Exceeded max attempts"))
    } else {
      setTimeout(executePoll, interval, resolve, reject)
    }
  }

  return new Promise(executePoll)
}
export { poll }