### This script plot correlation of Delta t with adjusted reference codon
### such that all selection coefficients are negative.

rm(list = ls())

suppressMessages(library(cubfits))

workflow.name <- "04_05-match_yassour"

# Specify workflows.
wf1.prefix <- "../04-wiphi_yassour/"
wf2.prefix <- "../05-fitsappr_yassour_HS/"
# Specify directory to save plots.
plot.prefix <- "./plot/"


# Load workflow 1.
source(paste(wf1.prefix, "00-set_env.r", sep = ""))

# Load data.
prefix$data <- paste(wf1.prefix, prefix$data, sep = "")
fn.in <- paste(prefix$data, "pre_process.rda", sep = "")
load(fn.in)

# Get AA and synonymous codons.
aa.names <- names(reu13.df.obs)
label <- NULL
for(i.aa in aa.names){
  tmp <- sort(unique(reu13.df.obs[[i.aa]]$Codon))
  tmp <- tmp[-length(tmp)]
  label <- c(label, paste(i.aa, tmp, sep = "."))
}


# Ordered by "ad_appr_pm", "ad_appr_scuo", "ad_fits_pm", and "ad_fits_scuo".
b.wf1.ci <- list()
b.wf1.mean <- list()
b.wf1.ci.org <- list()
b.wf1.mean.org <- list()
for(i.case in 1:4){
  # Subset of mcmc output
  prefix$subset <- paste(wf1.prefix, prefix$subset, sep = "")
  fn.in <- paste(prefix$subset, case.names[i.case], ".rda", sep = "")
  load(fn.in)

  b.wf1.ci.org[[i.case]] <- apply(b.mcmc, 1, quantile, prob = ci.prob)
  b.wf1.mean.org[[i.case]] <- rowMeans(b.mcmc)

  all.names <- rownames(b.mcmc)
  # id <- grep("(Intercept)", all.names, invert = TRUE)
  id.slop <- grep("Delta.t", all.names, invert = TRUE)
  scale.EPhi <- mean(rowMeans(phi.mcmc))

  b.mcmc[id.slop,] <- b.mcmc[id.slop,] * scale.EPhi
  b.wf1.ci[[i.case]] <- apply(b.mcmc, 1, quantile, prob = ci.prob)
  b.wf1.mean[[i.case]] <- rowMeans(b.mcmc)
}
case.names.wf1 <- case.names


### Load workflow 2.
source(paste(wf2.prefix, "00-set_env.r", sep = ""))

# Load data.
prefix$data <- paste(wf2.prefix, prefix$data, sep = "")
fn.in <- paste(prefix$data, "pre_process.rda", sep = "")
load(fn.in)

# Ordered by "ad_fits_pm", "ad_fits_scuo", "ad_appr_pm", and "ad_appr_scuo".
b.wf2.ci <- list()
b.wf2.mean <- list()
b.wf2.ci.org <- list()
b.wf2.mean.org <- list()
for(i.case in 1:4){
  # Subset of mcmc output
  prefix$subset <- paste(wf2.prefix, prefix$subset, sep = "")
  # fn.in <- paste(prefix$subset, case.names[i.case], ".rda", sep = "")
  fn.in <- paste(prefix$subset, case.names.wf1[i.case], ".rda", sep = "")
  load(fn.in)

  b.wf2.ci.org[[i.case]] <- apply(b.mcmc, 1, quantile, prob = ci.prob)
  b.wf2.mean.org[[i.case]] <- rowMeans(b.mcmc)

  all.names <- rownames(b.mcmc)
  # id <- grep("(Intercept)", all.names, invert = TRUE)
  id.slop <- grep("(Intercept)", all.names)
  scale.EPhi <- mean(rowMeans(phi.mcmc))

  b.mcmc[id.slop,] <- b.mcmc[id.slop,] * scale.EPhi
  b.wf2.ci[[i.case]] <- apply(b.mcmc, 1, quantile, prob = ci.prob)
  b.wf2.mean[[i.case]] <- rowMeans(b.mcmc)
}


# Plot S
# id <- grep("(Intercept)", all.names, invert = TRUE)
id.slop <- grep("Delta.t", all.names)

for(i.case in 1:4){
  if(i.case %in% 1:2){
    lab <- "Delta.t without phi"
  } else{
    lab <- "Delta.t with phi"
  }

  x <- b.wf1.mean[[i.case]][id.slop]
  y <- b.wf2.mean[[i.case]][id.slop]
  x.ci <- matrix(b.wf1.ci[[i.case]][, id.slop], nrow = 2)
  y.ci <- matrix(b.wf2.ci[[i.case]][, id.slop], nrow = 2)
  label.case <- label

  for(i.aa in aa.names){
    id.aa <- grep(paste(i.aa, "\\.", sep = ""), label)

    if(any(x[id.aa] > 0)){
      tmp <- max(x[id.aa])
      id.max <- which.max(x[id.aa])
      x[id.aa] <- x[id.aa] - tmp
      x[id.aa][id.max] <- -tmp
      if(length(id.aa) == 1){
        x.ci[, id.aa] <- -x.ci[, id.aa]
      } else{
        tmp.ci <- x.ci[, id.aa][, id.max]
        x.ci[, id.aa] <- x.ci[, id.aa] - tmp
        x.ci[, id.aa][, id.max] <- -tmp.ci
      }

      tmp <- max(y[id.aa])
      id.max <- which.max(y[id.aa])
      y[id.aa] <- y[id.aa] - tmp
      y[id.aa][id.max] <- -tmp
      if(length(id.aa) == 1){
        y.ci[, id.aa] <- -y.ci[, id.aa]
      } else{
        tmp.ci <- matrix(y.ci[, id.aa], nrow = 2)[, id.max]
        y.ci[, id.aa] <- y.ci[, id.aa] - tmp
        y.ci[, id.aa][, id.max] <- -tmp.ci
      }

      # Replace codon name.
      tmp <- .CF.GV$synonymous.codon[[i.aa]]
      if(i.aa == "S" && sum(id.aa) != length(tmp)){
        tmp <- .CF.GV$synonymous.codon.split[[i.aa]]
      }
      label.case[id.aa][id.max] <- paste(i.aa, ".", tmp[length(tmp)], sep = "")
    }
  }


  xlim <- range(x)
  ylim <- range(y)
  xlim <- xlim + c(-1, 1) * (xlim[2] - xlim[1]) * 0.05
  ylim <- ylim + c(-1, 1) * (ylim[2] - ylim[1]) * 0.05

  fn.out <- paste(plot.prefix, "wf_corr_negsel_deltat_", case.names.wf1[i.case],
                  ".pdf", sep = "")
  pdf(fn.out, width = 5, height = 5)
    plot(x, y, xlim = xlim, ylim = ylim, pch = 20, cex = 0.8,
         xlab = paste(lab, " Yassour", sep = ""),
         ylab = paste(lab, "Yassour_HS", sep = ""),
         main = case.names.wf1[i.case])
    title(sub = workflow.name, cex.sub = 0.6)
    for(i in 1:length(id.slop)){
      lines(x = x.ci[, i], y = rep(y[i], 2), col = 1)
      lines(x = rep(x[i], 2), y = y.ci[, i], col = 1)
    }
    abline(a = 0, b = 1, col = 4, lty = 2)
    # Add label
    x.split <- xlim[1] + (xlim[2] - xlim[1]) / 2
    tmp.id <- order(x)
    tmp.x <- x[tmp.id]
    tmp.y <- y[tmp.id]
    tmp.label <- label.case[tmp.id]
    x.adj <- (xlim[2] - xlim[1]) * 0.1 *
             rep(c(1, -1), c(sum(tmp.x <= x.split), sum(tmp.x > x.split))) *
             ((1:length(tmp.x) - 1) %% 3 + 1)
    tmp.x <- tmp.x + x.adj
    text(tmp.x, tmp.y, labels = tmp.label, cex = 0.4)
  dev.off()
}