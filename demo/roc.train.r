start.time <- proc.time()

library(cubfits)
set.seed(1234)

.CF.AC$renew.iter <- 3
ex.train$phi.Obs <- ex.train$phi.Obs / mean(ex.train$phi.Obs)
ret.time <- system.time({
  ret <- cubfits(ex.train$reu13.df, ex.train$phi.Obs, ex.train$y, ex.train$n,
                 nIter = 10, burnin = 10,
                 phi.DrawScale = 0.01,
                 verbose = TRUE, report = 5,
                 model = "roc", adaptive = "simple")
})
print(ret.time)

x <- rowMeans(do.call("cbind", ret$phi.Mat)[, 11:20])
y <- ex.train$phi.Obs
x <- log10(x / mean(x))
y <- log10(y / mean(y))
print(mean(x))
print(summary(lm(y ~ x))$r.squared)
# warning: iterations terminated because half-step sizes are very small

print(proc.time() - start.time)