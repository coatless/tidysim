# Copyright (C) 2015 - 2019  James Balamuta
#
# This file is part of `tidysim` R Package
#
# The `tidysim` R package is free software: you can redistribute it and/or modify
# it under the terms of the GPL-3 LICENSE included within the packages source
# as the LICENSE file.
#
# The `tidysim` R package is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# You should have received a copy of the GPL-3 License along with `tidysim`.
# If not, see <https://opensource.org/licenses/GPL-3.0>.

#' Cast Simulation Matrix to Data Frame
#'
#' Creates a `data.frame` out of a simulation matrix
#' for use with `ggplot2`.
#'
#' @param m     A `matrix`
#' @param wide  A `boolean` indicating if the simulated data is group
#'              by row (`TRUE`) or column (`FALSE`). Default: By row (`TRUE`).
#'
#' @return
#' A `data.frame` with three variables:
#'
#' - `Round`: Iteration of the Simulation
#' - `Draw`: Draw during the iteration of the simulation
#' - `Value`: Value of the statistic at round and draw
#'
#' @author
#' James Joseph Balamuta
#'
#' @export
#' @examples
#' # Set Seed
#' set.seed(5812)
#'
#' # Generate data
#' m = matrix(rnorm(10), 2,5)
#'
#' # Organize data.frame by row
#' sim_df(m)
#'
#' # Organize by column
#' sim_df(m, wide = FALSE)
sim_df = function(m, wide = TRUE){

    o = cast_simdf(m, wide)

    class(o) = c("sim_df", "data.frame")
    o
}

cast_simdf = function(m, wide = TRUE){
    if (!is.matrix(m)) {
        stop("`m` must be a `matrix`.")
    }

    n = nrow(m)
    p = ncol(m)

    if (wide) {
        Round = seq_len(n)
        Draw = seq_len(p)
    } else{
        Draw = seq_len(n)
        Round = seq_len(p)
    }

    # Hacked from as.data.frame(as.table())
    data.frame(expand.grid(Round = Round, Draw = Draw), Values = c(m))
}


#' Cast Simulation Study Matrices to Data.Frame
#'
#' Creates a `data.frame` out of multiple simulation matrices
#' for use with `ggplot2`.
#'
#' @param ...        A list of `matrices`
#' @param wide       A `boolean` indicating if the simulated data is group
#'                   by row (`TRUE`) or column (`FALSE`).
#' @param data_names A `character vector` containing name of matrix. If
#'                   empty it uses the simulation matrix name
#'
#' @return
#'
#' A `data.frame` with three variables:
#'
#' - `Round`: Iteration of the Simulation
#' - `Draw`: Draw during the iteration of the simulation
#' - `Value`: Value of the statistic at round and draw
#' - `Type`: Study Matrix
#'
#' @author
#' James Joseph Balamuta
#'
#' @export
#' @examples
#' # Set Seed
#' set.seed(5812)
#'
#' # Generate data
#' m1 = matrix(rnorm(10), 2, 5)
#' m2 = matrix(rnorm(10), 2, 5)
#' m3 = matrix(rnorm(10), 2, 5)
#'
#' # Organize data.frame by row
#' study_df(m1, m2, m3)
#'
#' # Organize by column
#' study_df(m1, m2, m3, wide = FALSE,
#'          data_names = c("Hello", "Goodbye", "Wabbit"))
study_df = function(..., wide = TRUE, data_names = NULL){


    obj_list = list(...)

    n = length(obj_list)

    if (length(data_names) != n) {
        message("No list of names detected... Substituting object names.")
        obj_names = as.character(substitute(...()))
    } else {
        obj_names = data_names
    }

    for (i in seq_along(obj_list)) {
        temp = cast_simdf(obj_list[[i]], wide = wide)

        temp$Type = obj_names[i]

        obj_list[[i]] = temp
    }

    o = Reduce(function(...)
        merge(..., all = TRUE), obj_list)

    class(o) = c("study_df", "data.frame")
    o
}

#' Plot Simulation Trials
#'
#' Constructs a line graph containing different simulations
#'
#' @param x,object An [`sim_df()`] object.
#' @param ...      Not used...
#' @rdname plot.simdf
#' @export
#' @examples
#' # Set Seed
#' set.seed(5812)
#'
#' # Generate data
#' m = matrix(rnorm(10), 2,5)
#'
#' # Organize data.frame by row
#' sim = sim_df(m)
#'
#' # Correct ggplot2 usage
#' autoplot(sim)
#'
#' # Base R
#' plot(sim)
plot.sim_df = function(x, ...){
    autoplot.sim_df(object = x, ...)
}

#' @export
#' @rdname plot.simdf
#' @importFrom ggplot2 autoplot
autoplot.sim_df = function(object, ...){

    Draw = Values = Round = NULL

    ggplot2::ggplot(object) +
        ggplot2::aes(
            x = Draw,
            y = Values,
            group = factor(Round),
            color = factor(Round)
        ) +
        ggplot2::geom_line(size = 1) +
        ggplot2::theme_bw() +
        ggplot2::labs(x = "Draw",
             y = "Values",
             color = "Round")
}
