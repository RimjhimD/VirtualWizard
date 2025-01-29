package com.example.virtualwizard.ui

import android.app.Activity
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.virtualwizard.ui.screens.*

object Routes {
    const val LOADING_SCREEN = "loading_screen"
    const val MAIN_MENU = "main_menu"
    const val SETTINGS = "settings"
    const val DEFEAT = "defeat"
    const val VICTORY = "victory"
    const val GAMEPLAY = "gameplay/{state}"
    const val FIGHTING_SCREEN = "fighting_screen/{state}"
}

@Composable
fun NavGraph(
    navController: NavHostController = rememberNavController()
) {
    val activity = LocalContext.current as? Activity

    NavHost(
        navController = navController,
        startDestination = Routes.LOADING_SCREEN
    ) {
        composable(Routes.LOADING_SCREEN) {
            LoadingScreen(
                onNavigateToMenu = {
                    navController.navigate(Routes.MAIN_MENU) {
                        popUpTo(Routes.LOADING_SCREEN) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.MAIN_MENU) {
            MainMenu(
                onResumeGame = { navController.navigate(Routes.GAMEPLAY.replace("{state}", "resume")) },
                onStartNewGame = { navController.navigate(Routes.GAMEPLAY.replace("{state}", "new")) },
                onOptions = { navController.navigate(Routes.SETTINGS) },
                onExit = { activity?.finish() }
            )
        }

        composable(Routes.SETTINGS) {
            Settings(onBackToMenu = { navController.navigateUp() })
        }

        composable(Routes.DEFEAT) {
            Defeat(
                onBackToMenu = {
                    navController.navigate(Routes.MAIN_MENU) {
                        popUpTo(Routes.DEFEAT) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.VICTORY) {
            Victory(
                onBackToMenu = {
                    navController.navigate(Routes.MAIN_MENU) {
                        popUpTo(Routes.VICTORY) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.GAMEPLAY) { backStackEntry ->
            val state = backStackEntry.arguments?.getString("state")
            Gameplay(
                state = state ?: "1",
                onNavigateToFighting = {
                    navController.navigate(Routes.FIGHTING_SCREEN.replace("{state}", state ?: "1"))
                }
            )
        }

        composable(Routes.FIGHTING_SCREEN) { backStackEntry ->
            val state = backStackEntry.arguments?.getString("state")
            FightingScreen(
                state = state ?: "1",
                onVictory = {
                    navController.navigate(Routes.VICTORY) {
                        popUpTo(Routes.FIGHTING_SCREEN) { inclusive = true }
                    }
                },
                onDefeat = {
                    navController.navigate(Routes.DEFEAT) {
                        popUpTo(Routes.FIGHTING_SCREEN) { inclusive = true }
                    }
                }
            )
        }
    }
}
