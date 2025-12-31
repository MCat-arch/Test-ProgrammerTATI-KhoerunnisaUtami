<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
        /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */

    public function handle(Request $request, Closure $next, string $role): Response
    {
    if (!Auth::check()) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    $userRole = Auth::user()->role->nama_role;
    
   
    $allowedRoles = explode('|', $role);

    // Cek apakah role user ada di dalam array yang diizinkan
    if (!in_array($userRole, $allowedRoles)) {
        return response()->json(['message' => 'Forbidden: Role not allowed'], 403);
    }

    return $next($request);
    }

}