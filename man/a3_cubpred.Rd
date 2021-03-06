\name{CUB Model Prediction}
\alias{cubpred}
\title{Codon Usage Bias Prediction for Observed ORFs}
\description{
  This function provides codon usage bias fits of training set
  which has observed ORFs and expressions possibly containing
  measurement errors, and provides predictions of testing set
  which has other observed ORFs but without expression.
}
\usage{
  cubpred(reu13.df.obs, phi.Obs, y, n,
          reu13.df.pred, y.pred, n.pred,
          nIter = 1000,
          b.Init = NULL, init.b.Scale = .CF.CONF$init.b.Scale,
              b.DrawScale = .CF.CONF$b.DrawScale,
              b.RInit = NULL,
          p.Init = NULL, p.nclass = .CF.CONF$p.nclass,
              p.DrawScale = .CF.CONF$p.DrawScale,
          phi.Init = NULL, init.phi.Scale = .CF.CONF$init.phi.Scale,
              phi.DrawScale = .CF.CONF$phi.DrawScale,
          phi.pred.Init = NULL,
              phi.pred.DrawScale = .CF.CONF$phi.pred.DrawScale,
          model = .CF.CT$model[1], model.Phi = .CF.CT$model.Phi[1],
          adaptive = .CF.CT$adaptive[1],
          verbose = .CF.DP$verbose,
          iterThin = .CF.DP$iterThin, report = .CF.DP$report)
}
\arguments{
  \item{reu13.df.obs}{a \code{\link{reu13.df}} to be trained.}
  \item{phi.Obs}{a \code{\link{phi.Obs}} to be trained.}
  \item{y}{a \code{\link{y}} to be trained.}
  \item{n}{a \code{\link{n}} to be trained.}
  \item{reu13.df.pred}{a \code{\link{reu13.df}} to be predicted.}
  \item{y.pred}{a \code{\link{y}} to be predicted.}
  \item{n.pred}{a \code{\link{n}} to be predicted.}
  \item{nIter}{number of iterations after burn-in iterations.}
  \item{b.Init}{initial values for parameters \code{\link{b}}.}
  \item{init.b.Scale}{for initial \code{\link{b}} if \code{b.Init = NULL}.}
  \item{b.DrawScale}{scaling factor for adaptive MCMC with random walks
                     when drawing new \code{\link{b}}.}
  \item{b.RInit}{initial values (in a list) for \code{R} matrices of
                 parameters \code{\link{b}} yielding from QR decomposition
                 of \code{vglm()} for the variance-covariance matrix of
                 \code{\link{b}}.}
  \item{p.Init}{initial values for hyper-parameters.}
  \item{p.nclass}{number of components for \code{model.Phi = "logmixture"}.}
  \item{p.DrawScale}{scaling factor for adaptive MCMC with random walks
                     when drawing new \code{sigma.Phi}.}
  \item{phi.Init}{initial values for Phi.}
  \item{init.phi.Scale}{for initial phi if \code{phi.Init = NULL}.}
  \item{phi.DrawScale}{scaling factor for adaptive MCMC with random walks
                       when drawing new Phi.}
  \item{phi.pred.Init}{initial values for Phi of predicted set.}
  \item{phi.pred.DrawScale}{as \code{phi.DrawScale} but for predicted set.}
  \item{model}{model to be fitted, currently "roc" only.}
  \item{model.Phi}{prior model for Phi, currently "lognormal".}
  \item{adaptive}{adaptive method of MCMC for proposing new \code{\link{b}}
                  and Phi.}
  \item{verbose}{print iteration messages.}
  \item{iterThin}{thinning iterations.}
  \item{report}{number of iterations to report more information.}
}
\details{
  This function correctly and carefully implements an extension of
  Shah and Gilchrist (2011) and Wallace et al. (2013).

  Total number of MCMC iterations is \code{nIter + 1}, but the
  outputs may be thinned to \code{nIter / iterThin + 1}
  iterations.

  Temporary result dumping may be controlled by \code{\link{.CF.DP}}.
}
\value{
  A list contains four big lists of MCMC traces including:
  \code{b.Mat} for mutation and selection coefficients of \code{\link{b}},
  \code{p.Mat} for hyper-parameters,
  \code{phi.Mat} for expected expression values Phi, and
  \code{phi.pred.Mat} for predictive expression values Phi.
  All lists have \code{nIter / iterThin + 1} elements,
  and each element contains the output of each iteration.

  All lists also can be binded as trace matrices, such as via
  \code{do.call("rbind", b.Mat)} yielding a matrix of dimension number of
  iterations by number of parameters. Then, those traces can be analyzed
  further via other MCMC packages such as \pkg{coda}.
}
\note{
  Note that \code{phi.Init} and \code{phi.pred.Init} need to be normalized
  to mean 1.

  \code{p.DrawScale} may cause scaling prior if adaptive MCMC is used, and
  it can result in non-exits of equilibrium distribution.
}
\references{
  \url{https://github.com/snoweye/cubfits/}

  Shah P. and Gilchrist M.A.
    ``Explaining complex codon usage patterns
      with selection for translational efficiency, mutation bias, and genetic
      drift''
    Proc Natl Acad Sci USA (2011) 108:10231--10236.
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}.
}
\seealso{
  \link{DataIO}, \link{DataConverting},
  \code{\link{cubfits}()} and \code{\link{cubappr}()}.
}
\examples{
\dontrun{
suppressMessages(library(cubfits, quietly = TRUE))

demo(roc.pred, 'cubfits', ask = F, echo = F)
}
}
\keyword{main function}
