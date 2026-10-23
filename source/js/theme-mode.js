(function () {
    "use strict";

    var storageKey = "pln-theme";
    var root = document.documentElement;
    var media = window.matchMedia("(prefers-color-scheme: dark)");

    function getStoredTheme() {
        try {
            var value = localStorage.getItem(storageKey);
            return value === "light" || value === "dark" ? value : null;
        } catch (error) {
            return null;
        }
    }

    function setStoredTheme(theme) {
        try {
            localStorage.setItem(storageKey, theme);
        } catch (error) {
            // localStorage may be unavailable in privacy-restricted contexts.
        }
    }

    function effectiveTheme() {
        var explicit = root.getAttribute("data-theme");
        if (explicit === "light" || explicit === "dark") {
            return explicit;
        }
        return media.matches ? "dark" : "light";
    }

    function applyInitialTheme() {
        var stored = getStoredTheme();
        if (stored) {
            root.setAttribute("data-theme", stored);
        } else {
            root.removeAttribute("data-theme");
        }
    }

    function updateToggle(button) {
        if (!button) return;

        var dark = effectiveTheme() === "dark";
        var icon = button.querySelector("i");

        if (icon) {
            icon.className = dark ? "fa fa-sun-o" : "fa fa-moon-o";
        }

        var label = dark ? "切换到浅色模式" : "切换到深色模式";
        button.setAttribute("aria-label", label);
        button.setAttribute("title", label);
    }

    function mountToggle() {
        var navbarRight = document.querySelector(".navbar-right");
        if (!navbarRight || document.getElementById("theme-toggle")) {
            return;
        }

        var item = document.createElement("li");
        item.id = "theme-toggle";
        item.className = "theme-toggle";

        var button = document.createElement("a");
        button.href = "#";
        button.setAttribute("role", "button");

        var icon = document.createElement("i");
        icon.setAttribute("aria-hidden", "true");

        button.appendChild(icon);
        item.appendChild(button);
        navbarRight.insertBefore(item, navbarRight.firstChild);

        updateToggle(button);

        button.addEventListener("click", function (event) {
            event.preventDefault();

            var next = effectiveTheme() === "dark" ? "light" : "dark";
            root.setAttribute("data-theme", next);
            setStoredTheme(next);
            updateToggle(button);
        });
    }

    applyInitialTheme();

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", mountToggle);
    } else {
        mountToggle();
    }

    var onSystemThemeChange = function () {
        if (!getStoredTheme()) {
            updateToggle(document.querySelector("#theme-toggle > a"));
        }
    };

    if (typeof media.addEventListener === "function") {
        media.addEventListener("change", onSystemThemeChange);
    } else if (typeof media.addListener === "function") {
        media.addListener(onSystemThemeChange);
    }
}());
